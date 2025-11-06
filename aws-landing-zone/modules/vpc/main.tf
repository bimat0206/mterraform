# Use the common tag module
module "tags" {
  source = "../../../common-modules/tag"

  environment  = var.environment
  owner        = var.owner
  cost_center  = var.cost_center
  project_name = var.project_name
}

locals {
  num_azs             = length(var.availability_zones)
  has_public_subnets  = length(var.public_subnet_cidrs) > 0
  has_private_subnets = length(var.private_subnet_cidrs) > 0
  has_tgw_subnets     = length(var.tgw_subnet_cidrs) > 0
  has_alb_subnets     = length(var.alb_subnet_cidrs) > 0

  # Ensure subnet lists match the number of AZs if provided
  public_subnet_cidrs  = local.has_public_subnets ? var.public_subnet_cidrs : []
  private_subnet_cidrs = local.has_private_subnets ? var.private_subnet_cidrs : []
  tgw_subnet_cidrs     = local.has_tgw_subnets ? var.tgw_subnet_cidrs : []
  alb_subnet_cidrs     = local.has_alb_subnets ? var.alb_subnet_cidrs : []

  # Create a consistent VPC name using prefix and name
  vpc_name = "${var.name_prefix}-${var.name}"
  
  # Extract AZ letters for resource naming (e.g., "us-east-1a" -> "a")
  az_letters = [for az in var.availability_zones : substr(az, length(az) - 1, 1)]
  
  # Use the vpc_name for tagging
  vpc_tags = merge(module.tags.tags, {
    Name = local.vpc_name
  })
}

resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = local.vpc_tags

  lifecycle {
    ignore_changes = [
      tags["CreationDate"]
    ]
  }
}

# --- VPC Flow Logs ---
resource "aws_cloudwatch_log_group" "flow_log" {
  count = var.enable_flow_logs ? 1 : 0
  
  name_prefix       = "/aws/vpc-flow-logs/${local.vpc_name}-"
  retention_in_days = var.flow_log_retention_in_days
  
  tags = merge(local.vpc_tags, {
    Name = "${local.vpc_name}-flow-logs"
  })

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      tags["CreationDate"]
    ]
  }


}

resource "aws_iam_role" "flow_log" {
  count = var.enable_flow_logs ? 1 : 0
  
  name = "${local.vpc_name}-flow-log-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })
  
  tags = local.vpc_tags

  lifecycle {
    ignore_changes = [
      tags["CreationDate"]
    ]
  }
}

resource "aws_iam_role_policy" "flow_log" {
  count = var.enable_flow_logs ? 1 : 0
  
  name = "${local.vpc_name}-vpc-flow-log-policy"
  role = aws_iam_role.flow_log[0].id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Effect = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_flow_log" "this" {
  count = var.enable_flow_logs ? 1 : 0
  
  iam_role_arn    = aws_iam_role.flow_log[0].arn
  log_destination = aws_cloudwatch_log_group.flow_log[0].arn
  traffic_type    = var.flow_log_traffic_type
  vpc_id          = aws_vpc.this.id
  
  tags = merge(local.vpc_tags, {
    Name = "${local.vpc_name}-flow-log"
  })

  lifecycle {
    ignore_changes = [
      tags["CreationDate"]
    ]
  }
  
  depends_on = [aws_cloudwatch_log_group.flow_log]
}





# --- Internet Gateway (for public subnets) ---
resource "aws_internet_gateway" "this" {
  count = local.has_public_subnets ? 1 : 0
  vpc_id = aws_vpc.this.id

  tags = merge(local.vpc_tags, {
    Name = "${local.vpc_name}-igw"
  })

  lifecycle {
    ignore_changes = [
      tags["CreationDate"]
    ]
  }
}

# --- Subnets ---
# Public subnets for internet-facing resources
resource "aws_subnet" "public" {
  count = local.has_public_subnets ? local.num_azs : 0

  vpc_id                  = aws_vpc.this.id
  cidr_block              = local.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(local.vpc_tags, {
    Name        = "${local.vpc_name}-public-${local.az_letters[count.index]}"
    Tier        = "public"
    NetworkZone = var.availability_zones[count.index]
  })

  lifecycle {
    ignore_changes = [
      tags["CreationDate"]
    ]
  }
}

resource "aws_subnet" "private" {
  count = local.has_private_subnets ? local.num_azs : 0

  vpc_id                  = aws_vpc.this.id
  cidr_block              = local.private_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = merge(local.vpc_tags, {
    Name        = "${local.vpc_name}-private-${local.az_letters[count.index]}"
    Tier        = "private"
    NetworkZone = var.availability_zones[count.index]
  })
}

# --- NEW TGW Subnets ---
resource "aws_subnet" "tgw" {
  count = local.has_tgw_subnets ? local.num_azs : 0

  vpc_id                  = aws_vpc.this.id
  cidr_block              = local.tgw_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false # TGW ENIs don't need public IPs

  tags = merge(local.vpc_tags, {
    Name        = "${local.vpc_name}-tgw-${local.az_letters[count.index]}"
    Tier        = "tgw" # Specific tier tag
    NetworkZone = var.availability_zones[count.index]
  })
}
# --- END NEW TGW Subnets ---

# --- ALB Subnets ---
resource "aws_subnet" "alb" {
  count = local.has_alb_subnets ? local.num_azs : 0

  vpc_id                  = aws_vpc.this.id
  cidr_block              = local.alb_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true  # Enable public IP mapping for ALB subnets

  tags = merge(local.vpc_tags, {
    Name        = lookup(var.subnet_names, "alb", [])[count.index] != null ? lookup(var.subnet_names, "alb", [])[count.index] : "${local.vpc_name}-alb-${local.az_letters[count.index]}"
    Tier        = "alb"
    NetworkZone = var.availability_zones[count.index]
  })
}

# --- ALB Route Table ---
resource "aws_route_table" "alb" {
  count = local.has_alb_subnets ? 1 : 0
  vpc_id = aws_vpc.this.id

  tags = merge(local.vpc_tags, {
    Name = "${local.vpc_name}-alb-uat-public-rt"
  })
}

# Internet Gateway route for ALB subnets
resource "aws_route" "alb_internet_gateway" {
  count = local.has_alb_subnets && local.has_public_subnets ? 1 : 0

  route_table_id         = aws_route_table.alb[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id

  depends_on = [aws_internet_gateway.this]
}

# Route for NAT Gateway(s) from ALB Subnets (for outbound traffic)
resource "aws_route" "alb_nat_gateway" {
  count = local.has_alb_subnets && var.enable_nat_gateway && local.has_public_subnets ? (var.single_nat_gateway ? 1 : local.num_azs) : 0

  route_table_id = aws_route_table.alb[0].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.this[var.single_nat_gateway ? 0 : count.index].id

  depends_on = [aws_nat_gateway.this]
}

resource "aws_route_table_association" "alb" {
  count = local.has_alb_subnets ? local.num_azs : 0

  subnet_id      = aws_subnet.alb[count.index].id
  route_table_id = aws_route_table.alb[0].id

  depends_on = [aws_route_table.alb]
}

# --- NAT Gateway & EIP (for private/tgw subnet egress) ---
# Placed in public subnets
resource "aws_eip" "nat" {
  # Create EIPs only if NAT GW is enabled and public subnets exist
  count = var.enable_nat_gateway && local.has_public_subnets ? (var.single_nat_gateway ? 1 : local.num_azs) : 0
  domain = "vpc"

  tags = merge(local.vpc_tags, {
    Name = var.single_nat_gateway ? "${local.vpc_name}-eip" : "${local.vpc_name}-eip-${local.az_letters[count.index]}"
  })

  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "this" {
  # Create NAT GWs only if NAT GW is enabled and public subnets exist
  count = var.enable_nat_gateway && local.has_public_subnets ? (var.single_nat_gateway ? 1 : local.num_azs) : 0

  allocation_id = aws_eip.nat[count.index].id
  # Place NAT GW in the corresponding public subnet
  subnet_id = aws_subnet.public[count.index].id

  tags = merge(local.vpc_tags, {
    Name = var.single_nat_gateway ? "${local.vpc_name}-natgw" : "${local.vpc_name}-natgw-${local.az_letters[count.index]}"
  })

  depends_on = [aws_internet_gateway.this]
}

# --- Route Tables ---

# Public Route Table
resource "aws_route_table" "public" {
  count = local.has_public_subnets ? 1 : 0
  vpc_id = aws_vpc.this.id

  tags = merge(local.vpc_tags, {
    Name = "${local.vpc_name}-public-rt"
  })

  lifecycle {
    ignore_changes = [
      tags["CreationDate"]
    ]
  }
}

resource "aws_route" "public_internet_gateway" {
  count = local.has_public_subnets ? 1 : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id

  depends_on = [aws_internet_gateway.this]
}

resource "aws_route_table_association" "public" {
  count = local.has_public_subnets ? local.num_azs : 0

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id
}

# Private Route Tables (for general-purpose private subnets)
resource "aws_route_table" "private" {
  # Create RTs if private subnets exist. One per AZ if using NAT GW per AZ and private subnets need NAT.
  count = local.has_private_subnets ? (var.enable_nat_gateway && !var.single_nat_gateway ? local.num_azs : 1) : 0
  vpc_id = aws_vpc.this.id

  tags = merge(local.vpc_tags, {
    Name = local.has_private_subnets && var.enable_nat_gateway && !var.single_nat_gateway ? "${local.vpc_name}-private-rt-${local.az_letters[count.index]}" : "${local.vpc_name}-private-rt"
  })

  lifecycle {
    ignore_changes = [
      tags["CreationDate"]
    ]
  }
}

# Route for NAT Gateway(s) from Private Subnets
resource "aws_route" "private_nat_gateway" {
  # Create a route per private route table if NAT GW is enabled
  count = local.has_private_subnets && var.enable_nat_gateway && local.has_public_subnets ? (var.single_nat_gateway ? 1 : local.num_azs) : 0

  route_table_id = aws_route_table.private[var.single_nat_gateway ? 0 : count.index].id
  destination_cidr_block = "0.0.0.0/0"
  # Route to the single NAT GW or the corresponding zonal NAT GW
  nat_gateway_id = aws_nat_gateway.this[var.single_nat_gateway ? 0 : count.index].id

  depends_on = [aws_nat_gateway.this]
}

resource "aws_route_table_association" "private" {
  count = local.has_private_subnets ? local.num_azs : 0

  subnet_id      = aws_subnet.private[count.index].id
  # Always use route_table.private[0] unless we have created multiple route tables (one per AZ)
  route_table_id = length(aws_route_table.private) > 1 ? aws_route_table.private[count.index].id : aws_route_table.private[0].id
}


# --- NEW TGW Route Tables ---
resource "aws_route_table" "tgw" {
  # Create RTs if TGW subnets exist. Typically one RT per AZ for TGW subnets if routing to zonal NAT GWs, otherwise one shared.
  # Let's use one per AZ if NAT GW is enabled per AZ AND route_outbound_tgw_subnets_to_nat is true, otherwise one shared.
  count = local.has_tgw_subnets ? (var.enable_nat_gateway && !var.single_nat_gateway && var.route_outbound_tgw_subnets_to_nat ? local.num_azs : 1) : 0
  vpc_id = aws_vpc.this.id

  tags = merge(local.vpc_tags, {
    Name = local.has_tgw_subnets && var.enable_nat_gateway && !var.single_nat_gateway && var.route_outbound_tgw_subnets_to_nat ? "${local.vpc_name}-tgw-rt-${local.az_letters[count.index]}" : "${local.vpc_name}-tgw-rt"
  })

  lifecycle {
    ignore_changes = [
      tags["CreationDate"]
    ]
  }
}

# --- NEW Route for NAT Gateway(s) from TGW Subnets (Conditional) ---
resource "aws_route" "tgw_nat_gateway" {
  # Create route only if: TGW subnets exist, NAT GW enabled, public subnets exist, AND flag is set
  count = local.has_tgw_subnets && var.enable_nat_gateway && local.has_public_subnets && var.route_outbound_tgw_subnets_to_nat ? (var.single_nat_gateway ? 1 : local.num_azs) : 0

  # Route goes into the TGW route table (shared or zonal)
  route_table_id = aws_route_table.tgw[var.single_nat_gateway ? 0 : count.index].id
  destination_cidr_block = "0.0.0.0/0"
  # Route to the single NAT GW or the corresponding zonal NAT GW
  nat_gateway_id = aws_nat_gateway.this[var.single_nat_gateway ? 0 : count.index].id

  depends_on = [aws_nat_gateway.this, aws_route_table.tgw]
}
# --- END NEW Route ---

resource "aws_route_table_association" "tgw" {
  count = local.has_tgw_subnets ? local.num_azs : 0

  subnet_id      = aws_subnet.tgw[count.index].id
  # Always use route_table.tgw[0] unless we have created multiple route tables (one per AZ)
  route_table_id = length(aws_route_table.tgw) > 1 ? aws_route_table.tgw[count.index].id : aws_route_table.tgw[0].id

  depends_on = [aws_route_table.tgw] # Ensure RT exists
}
# --- END NEW TGW Route Tables ---


# --- VPN Gateway (Optional) ---
resource "aws_vpn_gateway" "this" {
  count = var.enable_vpn_gateway ? 1 : 0
  vpc_id = aws_vpc.this.id

  tags = merge(local.vpc_tags, {
    Name = "${local.vpc_name}-vgw"
  })

  lifecycle {
    ignore_changes = [
      tags["CreationDate"]
    ]
  }
}
