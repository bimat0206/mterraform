# CloudWatch Log Groups for VPN Tunnels
resource "aws_cloudwatch_log_group" "tunnel1" {
  name              = "/aws/vpn/${local.vpn_name}/tunnel1"
  retention_in_days = 30

  tags = local.vpn_tags
}

resource "aws_cloudwatch_log_group" "tunnel2" {
  name              = "/aws/vpn/${local.vpn_name}/tunnel2"
  retention_in_days = 30

  tags = local.vpn_tags
}

# IAM Role for VPN CloudWatch Logs
resource "aws_iam_role" "vpn_cloudwatch" {
  name = "${local.vpn_name}-vpn-cloudwatch-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "logs.amazonaws.com"
        }
      }
    ]
  })

  tags = local.vpn_tags
}

# IAM Policy for VPN CloudWatch Logs
resource "aws_iam_role_policy" "vpn_cloudwatch" {
  name = "${local.vpn_name}-vpn-cloudwatch-policy"
  role = aws_iam_role.vpn_cloudwatch.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "S2SVPNLogging"
        Effect = "Allow"
        Action = [
          "logs:CreateLogDelivery",
          "logs:GetLogDelivery",
          "logs:UpdateLogDelivery",
          "logs:DeleteLogDelivery",
          "logs:ListLogDeliveries"
        ]
        Resource = ["*"]
      },
      {
        Sid = "S2SVPNLoggingCWL"
        Effect = "Allow"
        Action = [
          "logs:PutResourcePolicy",
          "logs:DescribeResourcePolicies",
          "logs:DescribeLogGroups"
        ]
        Resource = ["*"]
      }
    ]
  })
}

