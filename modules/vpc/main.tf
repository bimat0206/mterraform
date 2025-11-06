# -----------------------------------------------------------------------------
# Dynamic naming and tagging locals
# -----------------------------------------------------------------------------
locals {
  # Pick module default service if not provided
  _service = coalesce(var.service, "vpc")

  # Join tokens, drop empties
  _tokens = compact([var.org_prefix, var.environment, var.workload, local._service, var.identifier])
  _raw    = join("-", local._tokens)

  # Normalize to AWS-friendly style: lowercase + hyphens only
  name = trim(regexreplace(lower(local._raw), "[^a-z0-9-]", "-"), "-")

  # Get available AZs
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)

  # Calculate subnet CIDR blocks (evenly distribute across AZs)
  vpc_cidr_prefix = tonumber(split("/", var.cidr_block)[1])
  # Use /20 for subnets (4096 IPs each) - adjust as needed
  subnet_newbits = max(4, 20 - local.vpc_cidr_prefix)

  public_subnet_cidrs   = [for i in range(var.az_count) : cidrsubnet(var.cidr_block, local.subnet_newbits, i)]
  private_subnet_cidrs  = [for i in range(var.az_count) : cidrsubnet(var.cidr_block, local.subnet_newbits, i + var.az_count)]
  database_subnet_cidrs = var.create_database_subnets ? [for i in range(var.az_count) : cidrsubnet(var.cidr_block, local.subnet_newbits, i + (2 * var.az_count))] : []

  # NAT Gateway logic
  nat_gateway_count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : (var.one_nat_gateway_per_az ? var.az_count : 1)) : 0
}

# -----------------------------------------------------------------------------
# Data sources
# -----------------------------------------------------------------------------
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

# -----------------------------------------------------------------------------
# VPC
# -----------------------------------------------------------------------------
resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  instance_tenancy     = var.instance_tenancy
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  assign_generated_ipv6_cidr_block = var.enable_ipv6

  tags = merge(var.tags, {
    Name = local.name
  })
}

# -----------------------------------------------------------------------------
# Secondary CIDR Blocks
# -----------------------------------------------------------------------------
resource "aws_vpc_ipv4_cidr_block_association" "secondary" {
  count = length(var.secondary_cidr_blocks)

  vpc_id     = aws_vpc.this.id
  cidr_block = var.secondary_cidr_blocks[count.index]
}

# -----------------------------------------------------------------------------
# DHCP Options
# -----------------------------------------------------------------------------
resource "aws_vpc_dhcp_options" "this" {
  count = var.enable_dhcp_options ? 1 : 0

  domain_name          = var.dhcp_options_domain_name
  domain_name_servers  = var.dhcp_options_domain_name_servers
  ntp_servers          = var.dhcp_options_ntp_servers
  netbios_name_servers = var.dhcp_options_netbios_name_servers
  netbios_node_type    = var.dhcp_options_netbios_node_type

  tags = merge(var.tags, {
    Name = "${local.name}-dhcp-options"
  })
}

resource "aws_vpc_dhcp_options_association" "this" {
  count = var.enable_dhcp_options ? 1 : 0

  vpc_id          = aws_vpc.this.id
  dhcp_options_id = aws_vpc_dhcp_options.this[0].id
}

# -----------------------------------------------------------------------------
# Internet Gateway
# -----------------------------------------------------------------------------
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "${local.name}-igw"
  })
}

# -----------------------------------------------------------------------------
# VPN Gateway
# -----------------------------------------------------------------------------
resource "aws_vpn_gateway" "this" {
  count = var.enable_vpn_gateway ? 1 : 0

  vpc_id            = aws_vpc.this.id
  availability_zone = var.vpn_gateway_az

  tags = merge(var.tags, {
    Name = "${local.name}-vgw"
  })
}

# -----------------------------------------------------------------------------
# Public Subnets
# -----------------------------------------------------------------------------
resource "aws_subnet" "public" {
  count = var.az_count

  vpc_id                  = aws_vpc.this.id
  cidr_block              = local.public_subnet_cidrs[count.index]
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = var.map_public_ip_on_launch

  ipv6_cidr_block                 = var.enable_ipv6 ? cidrsubnet(aws_vpc.this.ipv6_cidr_block, 8, count.index) : null
  assign_ipv6_address_on_creation = var.enable_ipv6

  tags = merge(var.tags, {
    Name = "${local.name}-${var.public_subnet_suffix}-${local.azs[count.index]}"
    Tier = var.public_subnet_suffix
  })
}

# -----------------------------------------------------------------------------
# Private Subnets
# -----------------------------------------------------------------------------
resource "aws_subnet" "private" {
  count = var.az_count

  vpc_id            = aws_vpc.this.id
  cidr_block        = local.private_subnet_cidrs[count.index]
  availability_zone = local.azs[count.index]

  ipv6_cidr_block                 = var.enable_ipv6 ? cidrsubnet(aws_vpc.this.ipv6_cidr_block, 8, count.index + var.az_count) : null
  assign_ipv6_address_on_creation = false

  tags = merge(var.tags, {
    Name = "${local.name}-${var.private_subnet_suffix}-${local.azs[count.index]}"
    Tier = var.private_subnet_suffix
  })
}

# -----------------------------------------------------------------------------
# Database Subnets
# -----------------------------------------------------------------------------
resource "aws_subnet" "database" {
  count = var.create_database_subnets ? var.az_count : 0

  vpc_id            = aws_vpc.this.id
  cidr_block        = local.database_subnet_cidrs[count.index]
  availability_zone = local.azs[count.index]

  tags = merge(var.tags, {
    Name = "${local.name}-${var.database_subnet_suffix}-${local.azs[count.index]}"
    Tier = var.database_subnet_suffix
  })
}

resource "aws_db_subnet_group" "this" {
  count = var.create_database_subnet_group && var.create_database_subnets ? 1 : 0

  name        = "${local.name}-db-subnet-group"
  description = "Database subnet group for ${local.name}"
  subnet_ids  = aws_subnet.database[*].id

  tags = merge(var.tags, {
    Name = "${local.name}-db-subnet-group"
  })
}

# -----------------------------------------------------------------------------
# NAT Gateway
# -----------------------------------------------------------------------------
resource "aws_eip" "nat" {
  count = local.nat_gateway_count

  domain = "vpc"

  tags = merge(var.tags, {
    Name = "${local.name}-nat-eip-${count.index + 1}"
  })

  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "this" {
  count = local.nat_gateway_count

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[var.single_nat_gateway ? 0 : count.index].id

  tags = merge(var.tags, {
    Name = "${local.name}-nat-${count.index + 1}"
  })

  depends_on = [aws_internet_gateway.this]
}

# -----------------------------------------------------------------------------
# Route Tables - Public
# -----------------------------------------------------------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "${local.name}-public-rt"
    Tier = "public"
  })
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route" "public_internet_gateway_ipv6" {
  count = var.enable_ipv6 ? 1 : 0

  route_table_id              = aws_route_table.public.id
  destination_ipv6_cidr_block = "::/0"
  gateway_id                  = aws_internet_gateway.this.id
}

resource "aws_vpn_gateway_route_propagation" "public" {
  count = var.enable_vpn_gateway && var.propagate_vpn_routes_to_public_route_tables ? 1 : 0

  vpn_gateway_id = aws_vpn_gateway.this[0].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public" {
  count = var.az_count

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# -----------------------------------------------------------------------------
# Route Tables - Private
# -----------------------------------------------------------------------------
resource "aws_route_table" "private" {
  count = var.single_nat_gateway ? 1 : var.az_count

  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = var.single_nat_gateway ? "${local.name}-private-rt" : "${local.name}-private-rt-${local.azs[count.index]}"
    Tier = "private"
  })
}

resource "aws_route" "private_nat_gateway" {
  count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : var.az_count) : 0

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.single_nat_gateway ? aws_nat_gateway.this[0].id : aws_nat_gateway.this[count.index].id
}

resource "aws_vpn_gateway_route_propagation" "private" {
  count = var.enable_vpn_gateway && var.propagate_vpn_routes_to_private_route_tables ? (var.single_nat_gateway ? 1 : var.az_count) : 0

  vpn_gateway_id = aws_vpn_gateway.this[0].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_route_table_association" "private" {
  count = var.az_count

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = var.single_nat_gateway ? aws_route_table.private[0].id : aws_route_table.private[count.index].id
}

# -----------------------------------------------------------------------------
# Route Tables - Database
# -----------------------------------------------------------------------------
resource "aws_route_table" "database" {
  count = var.create_database_subnets ? (var.single_nat_gateway ? 1 : var.az_count) : 0

  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = var.single_nat_gateway ? "${local.name}-database-rt" : "${local.name}-database-rt-${local.azs[count.index]}"
    Tier = "database"
  })
}

resource "aws_route" "database_nat_gateway" {
  count = var.create_database_subnets && var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : var.az_count) : 0

  route_table_id         = aws_route_table.database[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.single_nat_gateway ? aws_nat_gateway.this[0].id : aws_nat_gateway.this[count.index].id
}

resource "aws_route_table_association" "database" {
  count = var.create_database_subnets ? var.az_count : 0

  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = var.single_nat_gateway ? aws_route_table.database[0].id : aws_route_table.database[count.index].id
}

# -----------------------------------------------------------------------------
# Default Route Table Management
# -----------------------------------------------------------------------------
resource "aws_default_route_table" "default" {
  count = var.manage_default_route_table ? 1 : 0

  default_route_table_id = aws_vpc.this.default_route_table_id

  dynamic "route" {
    for_each = var.default_route_table_routes
    content {
      cidr_block                 = lookup(route.value, "cidr_block", null)
      ipv6_cidr_block            = lookup(route.value, "ipv6_cidr_block", null)
      egress_only_gateway_id     = lookup(route.value, "egress_only_gateway_id", null)
      gateway_id                 = lookup(route.value, "gateway_id", null)
      nat_gateway_id             = lookup(route.value, "nat_gateway_id", null)
      network_interface_id       = lookup(route.value, "network_interface_id", null)
      transit_gateway_id         = lookup(route.value, "transit_gateway_id", null)
      vpc_peering_connection_id  = lookup(route.value, "vpc_peering_connection_id", null)
    }
  }

  tags = merge(var.tags, {
    Name = "${local.name}-default-rt"
  })
}

# -----------------------------------------------------------------------------
# VPC Flow Logs
# -----------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "flow_logs" {
  count = var.enable_flow_logs && var.flow_logs_destination_type == "cloud-watch-logs" && var.flow_logs_destination_arn == "" ? 1 : 0

  name              = "/aws/vpc/flowlogs/${local.name}"
  retention_in_days = var.flow_logs_retention_days

  tags = merge(var.tags, {
    Name = "${local.name}-flow-logs"
  })
}

resource "aws_iam_role" "flow_logs" {
  count = var.enable_flow_logs && var.flow_logs_destination_type == "cloud-watch-logs" ? 1 : 0

  name = "${local.name}-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${local.name}-flow-logs-role"
  })
}

resource "aws_iam_role_policy" "flow_logs" {
  count = var.enable_flow_logs && var.flow_logs_destination_type == "cloud-watch-logs" ? 1 : 0

  name = "${local.name}-flow-logs-policy"
  role = aws_iam_role.flow_logs[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_flow_log" "this" {
  count = var.enable_flow_logs ? 1 : 0

  vpc_id          = aws_vpc.this.id
  traffic_type    = var.flow_logs_traffic_type
  iam_role_arn    = var.flow_logs_destination_type == "cloud-watch-logs" ? aws_iam_role.flow_logs[0].arn : null
  log_destination = var.flow_logs_destination_arn != "" ? var.flow_logs_destination_arn : (var.flow_logs_destination_type == "cloud-watch-logs" ? aws_cloudwatch_log_group.flow_logs[0].arn : null)
  log_destination_type = var.flow_logs_destination_type

  tags = merge(var.tags, {
    Name = "${local.name}-flow-logs"
  })
}

# -----------------------------------------------------------------------------
# Network ACLs - Default
# -----------------------------------------------------------------------------
resource "aws_default_network_acl" "default" {
  count = var.manage_default_network_acl ? 1 : 0

  default_network_acl_id = aws_vpc.this.default_network_acl_id

  dynamic "ingress" {
    for_each = var.default_network_acl_ingress
    content {
      action          = lookup(ingress.value, "action", "allow")
      cidr_block      = lookup(ingress.value, "cidr_block", null)
      from_port       = lookup(ingress.value, "from_port", 0)
      icmp_code       = lookup(ingress.value, "icmp_code", null)
      icmp_type       = lookup(ingress.value, "icmp_type", null)
      ipv6_cidr_block = lookup(ingress.value, "ipv6_cidr_block", null)
      protocol        = lookup(ingress.value, "protocol", "-1")
      rule_no         = lookup(ingress.value, "rule_no", 100)
      to_port         = lookup(ingress.value, "to_port", 0)
    }
  }

  dynamic "egress" {
    for_each = var.default_network_acl_egress
    content {
      action          = lookup(egress.value, "action", "allow")
      cidr_block      = lookup(egress.value, "cidr_block", null)
      from_port       = lookup(egress.value, "from_port", 0)
      icmp_code       = lookup(egress.value, "icmp_code", null)
      icmp_type       = lookup(egress.value, "icmp_type", null)
      ipv6_cidr_block = lookup(egress.value, "ipv6_cidr_block", null)
      protocol        = lookup(egress.value, "protocol", "-1")
      rule_no         = lookup(egress.value, "rule_no", 100)
      to_port         = lookup(egress.value, "to_port", 0)
    }
  }

  tags = merge(var.tags, {
    Name = "${local.name}-default-nacl"
  })
}

# -----------------------------------------------------------------------------
# Network ACLs - Public
# -----------------------------------------------------------------------------
resource "aws_network_acl" "public" {
  count = var.public_dedicated_network_acl ? 1 : 0

  vpc_id     = aws_vpc.this.id
  subnet_ids = aws_subnet.public[*].id

  tags = merge(var.tags, {
    Name = "${local.name}-public-nacl"
    Tier = "public"
  })
}

# -----------------------------------------------------------------------------
# Network ACLs - Private
# -----------------------------------------------------------------------------
resource "aws_network_acl" "private" {
  count = var.private_dedicated_network_acl ? 1 : 0

  vpc_id     = aws_vpc.this.id
  subnet_ids = aws_subnet.private[*].id

  tags = merge(var.tags, {
    Name = "${local.name}-private-nacl"
    Tier = "private"
  })
}

# -----------------------------------------------------------------------------
# Default Security Group
# -----------------------------------------------------------------------------
resource "aws_default_security_group" "default" {
  count = var.manage_default_security_group ? 1 : 0

  vpc_id = aws_vpc.this.id

  dynamic "ingress" {
    for_each = var.default_security_group_ingress
    content {
      description      = lookup(ingress.value, "description", null)
      cidr_blocks      = lookup(ingress.value, "cidr_blocks", null)
      from_port        = lookup(ingress.value, "from_port", 0)
      ipv6_cidr_blocks = lookup(ingress.value, "ipv6_cidr_blocks", null)
      prefix_list_ids  = lookup(ingress.value, "prefix_list_ids", null)
      protocol         = lookup(ingress.value, "protocol", "-1")
      security_groups  = lookup(ingress.value, "security_groups", null)
      self             = lookup(ingress.value, "self", null)
      to_port          = lookup(ingress.value, "to_port", 0)
    }
  }

  dynamic "egress" {
    for_each = var.default_security_group_egress
    content {
      description      = lookup(egress.value, "description", null)
      cidr_blocks      = lookup(egress.value, "cidr_blocks", null)
      from_port        = lookup(egress.value, "from_port", 0)
      ipv6_cidr_blocks = lookup(egress.value, "ipv6_cidr_blocks", null)
      prefix_list_ids  = lookup(egress.value, "prefix_list_ids", null)
      protocol         = lookup(egress.value, "protocol", "-1")
      security_groups  = lookup(egress.value, "security_groups", null)
      self             = lookup(egress.value, "self", null)
      to_port          = lookup(egress.value, "to_port", 0)
    }
  }

  tags = merge(var.tags, {
    Name = "${local.name}-default-sg"
  })
}
