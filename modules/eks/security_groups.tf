# -----------------------------------------------------------------------------
# Security Group for EKS Cluster
# -----------------------------------------------------------------------------
resource "aws_security_group" "cluster" {
  name        = "${local.name}-cluster-sg"
  description = "Security group for ${local.name} EKS cluster"
  vpc_id      = var.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-cluster-sg"
    }
  )
}

resource "aws_security_group_rule" "cluster_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.cluster.id
  description       = "Allow all outbound traffic"
}

resource "aws_vpc_security_group_ingress_rule" "cluster_additional" {
  for_each = { for k, v in var.cluster_security_group_additional_rules : k => v if v.type == "ingress" }

  security_group_id            = aws_security_group.cluster.id
  from_port                    = each.value.from_port
  to_port                      = each.value.to_port
  ip_protocol                  = each.value.protocol
  cidr_ipv4                    = length(each.value.cidr_blocks) > 0 ? each.value.cidr_blocks[0] : null
  referenced_security_group_id = each.value.source_security_group_id != "" ? each.value.source_security_group_id : null
  description                  = each.value.description

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-cluster-ingress-${each.key}"
    }
  )
}

# -----------------------------------------------------------------------------
# Security Group for Node Groups
# -----------------------------------------------------------------------------
resource "aws_security_group" "node_group" {
  name        = "${local.name}-node-sg"
  description = "Security group for ${local.name} EKS node groups"
  vpc_id      = var.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name                                        = "${local.name}-node-sg"
      "kubernetes.io/cluster/${local.name}"       = "owned"
    }
  )
}

resource "aws_security_group_rule" "node_group_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.node_group.id
  description       = "Allow all outbound traffic"
}

resource "aws_security_group_rule" "node_group_ingress_self" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  source_security_group_id = aws_security_group.node_group.id
  security_group_id        = aws_security_group.node_group.id
  description              = "Allow nodes to communicate with each other"
}

resource "aws_security_group_rule" "node_group_ingress_cluster" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  source_security_group_id = aws_security_group.cluster.id
  security_group_id        = aws_security_group.node_group.id
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
}

resource "aws_security_group_rule" "cluster_ingress_node_https" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.node_group.id
  security_group_id        = aws_security_group.cluster.id
  description              = "Allow pods to communicate with the cluster API Server"
}

resource "aws_vpc_security_group_ingress_rule" "node_group_additional" {
  for_each = { for k, v in var.node_security_group_additional_rules : k => v if v.type == "ingress" }

  security_group_id            = aws_security_group.node_group.id
  from_port                    = each.value.from_port
  to_port                      = each.value.to_port
  ip_protocol                  = each.value.protocol
  cidr_ipv4                    = length(each.value.cidr_blocks) > 0 ? each.value.cidr_blocks[0] : null
  referenced_security_group_id = each.value.source_security_group_id != "" ? each.value.source_security_group_id : null
  description                  = each.value.description

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-node-ingress-${each.key}"
    }
  )
}
