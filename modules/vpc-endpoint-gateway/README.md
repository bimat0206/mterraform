# VPC Gateway Endpoints Module

Creates AWS VPC Gateway Endpoints for S3 and DynamoDB. Gateway endpoints are free and provide private connectivity to these AWS services without requiring internet access.

## Features

- **S3 Gateway Endpoint**: Private access to S3 buckets (FREE)
- **DynamoDB Gateway Endpoint**: Private access to DynamoDB tables (FREE)
- **Route Table Association**: Automatic association with specified route tables
- **Policy Support**: Optional IAM policies for access control
- **Consistent Naming**: Dynamic naming based on organizational standards

## Cost

Gateway endpoints are **FREE** - no hourly charges or data processing charges. This makes them ideal for cost optimization compared to NAT Gateway or interface endpoints.

## Usage

### Basic Usage

```hcl
module "vpc_gateway_endpoints" {
  source = "../modules/vpc-endpoint-gateway"

  # Naming
  org_prefix  = "tsk"
  environment = "prod"
  workload    = "app"
  identifier  = "01"

  # VPC Configuration
  vpc_id = module.vpc.vpc_id

  # Enable endpoints
  enable_s3_endpoint       = true
  enable_dynamodb_endpoint = true

  # Associate with route tables
  route_table_ids = concat(
    [module.vpc.public_route_table_id],
    module.vpc.private_route_table_ids
  )

  tags = {}
}
```

### With Custom Policies

```hcl
module "vpc_gateway_endpoints" {
  source = "../modules/vpc-endpoint-gateway"

  org_prefix  = "tsk"
  environment = "prod"
  workload    = "app"

  vpc_id = module.vpc.vpc_id

  enable_s3_endpoint = true

  # Restrict S3 access to specific buckets
  s3_endpoint_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = [
          "arn:aws:s3:::my-app-bucket/*",
          "arn:aws:s3:::my-logs-bucket/*"
        ]
      }
    ]
  })

  route_table_ids = module.vpc.private_route_table_ids

  tags = {}
}
```

### S3 Only (Most Common)

```hcl
module "s3_endpoint" {
  source = "../modules/vpc-endpoint-gateway"

  org_prefix  = "tsk"
  environment = "dev"
  workload    = "app"

  vpc_id = module.vpc.vpc_id

  # Only enable S3
  enable_s3_endpoint       = true
  enable_dynamodb_endpoint = false

  route_table_ids = module.vpc.private_route_table_ids

  tags = {}
}
```

## Variables

### Naming Variables

| Name | Type | Default | Description |
|------|------|---------|-------------|
| org_prefix | string | - | Organization prefix (Required) |
| environment | string | - | Environment name (Required) |
| workload | string | - | Workload name (Required) |
| service | string | null | Service override (default: "vpce-gw") |
| identifier | string | null | Unique identifier |
| tags | map(string) | {} | Additional tags |

### Configuration Variables

| Name | Type | Default | Description |
|------|------|---------|-------------|
| vpc_id | string | - | VPC ID (Required) |
| enable_s3_endpoint | bool | true | Enable S3 endpoint |
| enable_dynamodb_endpoint | bool | false | Enable DynamoDB endpoint |
| route_table_ids | list(string) | - | Route tables to associate (Required) |
| s3_endpoint_policy | string | null | S3 endpoint IAM policy (JSON) |
| dynamodb_endpoint_policy | string | null | DynamoDB endpoint IAM policy (JSON) |

## Outputs

### S3 Endpoint Outputs

| Name | Description |
|------|-------------|
| s3_endpoint_id | S3 endpoint ID |
| s3_endpoint_arn | S3 endpoint ARN |
| s3_endpoint_prefix_list_id | S3 prefix list ID |
| s3_endpoint_cidr_blocks | S3 service CIDR blocks |
| s3_endpoint_state | S3 endpoint state |

### DynamoDB Endpoint Outputs

| Name | Description |
|------|-------------|
| dynamodb_endpoint_id | DynamoDB endpoint ID |
| dynamodb_endpoint_arn | DynamoDB endpoint ARN |
| dynamodb_endpoint_prefix_list_id | DynamoDB prefix list ID |
| dynamodb_endpoint_cidr_blocks | DynamoDB service CIDR blocks |
| dynamodb_endpoint_state | DynamoDB endpoint state |

## Resource Naming

Resources are named using: `{org_prefix}-{environment}-{workload}-{service}-{identifier}`

Example: `tsk-prod-app-vpce-gw-01-s3`

## Benefits of Gateway Endpoints

1. **Cost Savings**: FREE vs NAT Gateway ($32+/month) or Interface Endpoints ($7.20/month)
2. **Performance**: Direct AWS backbone connectivity, lower latency
3. **Security**: Private connectivity, no internet exposure
4. **Scalability**: Automatically scales with your traffic
5. **No Maintenance**: Fully managed by AWS

## Use Cases

- **S3 Access**: EC2 instances, Lambda functions, ECS tasks accessing S3 buckets
- **DynamoDB Access**: Applications reading/writing to DynamoDB tables
- **Cost Optimization**: Replace NAT Gateway traffic for S3/DynamoDB
- **Compliance**: Keep data traffic within AWS network (no internet)

## Best Practices

1. **Always Enable for S3**: Unless you have specific reasons not to, always enable S3 gateway endpoints
2. **Route Table Coverage**: Include all route tables that need S3/DynamoDB access
3. **Endpoint Policies**: Use restrictive policies for production environments
4. **Monitor Usage**: Use VPC Flow Logs to verify endpoint usage
5. **Security Groups**: Remember gateway endpoints don't use security groups (route-table based)

## Security Considerations

- Gateway endpoints use **route-based** filtering (not security groups)
- Use endpoint policies to restrict access to specific resources
- Consider using VPC endpoint policies for least-privilege access
- Combine with S3 bucket policies for defense-in-depth

## Troubleshooting

### Endpoint Not Working

1. **Check route table associations**: Verify endpoint is associated with correct route tables
2. **Review endpoint policy**: Ensure policy allows required actions
3. **Check S3 bucket policy**: Bucket policy may be blocking VPC endpoint access
4. **Verify VPC ID**: Endpoint must be in the same VPC as resources

### Policy Errors

1. **Valid JSON**: Ensure policy is valid JSON
2. **IAM Policy Syntax**: Follow AWS IAM policy syntax
3. **Resource ARNs**: Use correct ARN format for S3 buckets/DynamoDB tables

## Examples

See `../../network-account/` for complete examples using this module.

## Requirements

- Terraform >= 1.6.0
- AWS Provider ~> 5.0

## Related Modules

- `../vpc/` - VPC infrastructure
- `../vpc-endpoint-interface/` - Interface VPC endpoints

## Cost Comparison

| Solution | Monthly Cost | Use Case |
|----------|--------------|----------|
| Gateway Endpoint | $0 | S3, DynamoDB access |
| NAT Gateway | $32+ (+ data) | Internet access |
| Interface Endpoint | $7.20+ (+ data) | Other AWS services |

**Recommendation**: Always use gateway endpoints for S3 and DynamoDB to save costs.
