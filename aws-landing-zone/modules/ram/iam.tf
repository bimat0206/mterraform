# IAM Role and Policy for RAM sharing
resource "aws_iam_role" "ram_sharing_role" {
  name = "${var.name_prefix}-ram-sharing-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ram.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    module.tags.tags,
    {
      Name = "${var.name_prefix}-ram-sharing-role"
    }
  )
}

# Policy to allow RAM sharing operations
resource "aws_iam_policy" "ram_sharing_policy" {
  name        = "${var.name_prefix}-ram-sharing-policy"
  description = "Policy to allow RAM sharing operations for resources"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ram:CreateResourceShare",
          "ram:UpdateResourceShare",
          "ram:DeleteResourceShare",
          "ram:AssociateResourceShare",
          "ram:DisassociateResourceShare",
          "ram:AssociateResourceSharePermission",
          "ram:DisassociateResourceSharePermission",
          "ram:EnableSharingWithAwsOrganization"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "route53profiles:*",
          "ec2:*TransitGateway*"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "route53resolver:CreateResolverQueryLogConfig",
          "route53resolver:DeleteResolverQueryLogConfig",
          "route53resolver:GetResolverQueryLogConfig",
          "route53resolver:ListResolverQueryLogConfigs",
          "route53resolver:AssociateResolverQueryLogConfig",
          "route53resolver:DisassociateResolverQueryLogConfig"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "organizations:DescribeOrganization",
          "organizations:ListAccounts",
          "organizations:ListOrganizationalUnitsForParent",
          "organizations:ListRoots"
        ],
        Resource = "*"
      }
    ]
  })
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "ram_sharing_policy_attachment" {
  role       = aws_iam_role.ram_sharing_role.name
  policy_arn = aws_iam_policy.ram_sharing_policy.arn
}

# Attach the AWS managed policy for Route53 Profiles
resource "aws_iam_role_policy_attachment" "route53_profiles_policy_attachment" {
  role       = aws_iam_role.ram_sharing_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRoute53ProfilesFullAccess"
}
