# AWS Transit Gateway Module

Terraform module for creating and managing AWS Transit Gateway with comprehensive Flow Logs, CloudWatch monitoring, VPC attachments, and resource sharing capabilities.

## Features

- **Transit Gateway**: Centralized network hub for connecting VPCs and on-premises networks
- **Flow Logs**: Complete traffic visibility with CloudWatch Logs or S3 destination
- **CloudWatch Alarms**: Automated monitoring for traffic and packet drops
- **VPC Attachments**: Automatic attachment to multiple VPCs
- **Custom Route Tables**: Support for complex routing scenarios
- **Resource Sharing**: AWS RAM integration for multi-account deployments
- **BGP Support**: Configurable ASN for BGP sessions
- **VPN ECMP**: Equal Cost Multipath for VPN connections
- **DNS Support**: DNS resolution across attached VPCs
- **Appliance Mode**: Support for network appliances and firewalls

## Use Cases

1. **Hub-and-Spoke Architecture**: Connect multiple VPCs through a central Transit Gateway
2. **Multi-Account Connectivity**: Share Transit Gateway across AWS accounts
3. **Hybrid Cloud**: Connect on-premises networks via VPN or Direct Connect
4. **Network Segmentation**: Isolate traffic using custom route tables
5. **Centralized Inspection**: Route traffic through security appliances

## Usage

### Basic Example

```hcl
module "transit_gateway" {
  source = "../modules/transit-gateway"

  # Naming
  org_prefix  = "myorg"
  environment = "prod"
  workload    = "network"
  identifier  = "01"

  # Basic Configuration
  description     = "Production Transit Gateway"
  amazon_side_asn = 64512

  # Flow Logs
  enable_flow_logs           = true
  flow_logs_retention_days   = 30
  flow_logs_destination_type = "cloud-watch-logs"

  # CloudWatch Alarms
  enable_cloudwatch_alarms = true

  tags = {
    Project = "NetworkHub"
  }
}
```

### VPC Attachments Example

```hcl
module "transit_gateway" {
  source = "../modules/transit-gateway"

  org_prefix  = "myorg"
  environment = "prod"
  workload    = "network"

  # VPC Attachments
  vpc_attachments = {
    vpc-prod-app = {
      vpc_id     = "vpc-xxxxx"
      subnet_ids = ["subnet-xxxxx", "subnet-yyyyy"]
      dns_support                                     = "enable"
      ipv6_support                                    = "disable"
      appliance_mode_support                          = "disable"
      transit_gateway_default_route_table_association = true
      transit_gateway_default_route_table_propagation = true
    }
    vpc-prod-data = {
      vpc_id     = "vpc-zzzzz"
      subnet_ids = ["subnet-aaaaa", "subnet-bbbbb"]
      dns_support                                     = "enable"
      transit_gateway_default_route_table_association = true
      transit_gateway_default_route_table_propagation = true
    }
  }

  # Flow Logs
  enable_flow_logs         = true
  flow_logs_retention_days = 7

  tags = {
    Environment = "Production"
  }
}
```

### Advanced Example with Custom Route Tables

```hcl
module "transit_gateway" {
  source = "../modules/transit-gateway"

  org_prefix  = "myorg"
  environment = "prod"
  workload    = "network"

  # Transit Gateway Configuration
  description                     = "Production Transit Gateway with custom routing"
  amazon_side_asn                 = 64512
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"

  # VPC Attachments (with manual route table association)
  vpc_attachments = {
    vpc-prod-web = {
      vpc_id                                          = "vpc-xxxxx"
      subnet_ids                                      = ["subnet-xxxxx", "subnet-yyyyy"]
      transit_gateway_default_route_table_association = false
      transit_gateway_default_route_table_propagation = false
    }
    vpc-prod-app = {
      vpc_id                                          = "vpc-zzzzz"
      subnet_ids                                      = ["subnet-aaaaa", "subnet-bbbbb"]
      transit_gateway_default_route_table_association = false
      transit_gateway_default_route_table_propagation = false
    }
    vpc-prod-db = {
      vpc_id                                          = "vpc-ccccc"
      subnet_ids                                      = ["subnet-ddddd", "subnet-eeeee"]
      transit_gateway_default_route_table_association = false
      transit_gateway_default_route_table_propagation = false
    }
  }

  # Custom Route Tables
  create_custom_route_tables = true
  custom_route_tables = {
    web-tier = {
      name = "web-tier"
    }
    app-tier = {
      name = "app-tier"
    }
    data-tier = {
      name = "data-tier"
    }
  }

  # Flow Logs to S3
  enable_flow_logs           = true
  flow_logs_destination_type = "s3"
  flow_logs_s3_bucket_arn    = "arn:aws:s3:::my-tgw-flow-logs-bucket"

  # CloudWatch Alarms with SNS
  enable_cloudwatch_alarms              = true
  alarm_sns_topic_arn                   = "arn:aws:sns:us-east-1:123456789012:tgw-alarms"
  bytes_in_threshold                    = 5000000000  # 5 GB
  bytes_out_threshold                   = 5000000000  # 5 GB
  packet_drop_count_blackhole_threshold = 10000
  packet_drop_count_no_route_threshold  = 10000

  tags = {
    Environment = "Production"
    CostCenter  = "Network"
    Compliance  = "PCI-DSS"
  }
}
```

### Multi-Account Resource Sharing Example

```hcl
module "transit_gateway" {
  source = "../modules/transit-gateway"

  org_prefix  = "myorg"
  environment = "prod"
  workload    = "network"

  # Basic Configuration
  description                    = "Shared Transit Gateway"
  auto_accept_shared_attachments = "enable"

  # Resource Sharing
  enable_resource_sharing        = true
  ram_allow_external_principals  = false
  ram_principals = [
    "arn:aws:organizations::123456789012:organization/o-xxxxx",  # Share with entire organization
    # OR share with specific accounts:
    # "123456789012",
    # "234567890123"
  ]

  # Flow Logs
  enable_flow_logs         = true
  flow_logs_retention_days = 90

  tags = {
    Shared = "true"
  }
}
```

## Flow Logs

Transit Gateway Flow Logs capture information about IP traffic going to and from network interfaces in your Transit Gateway.

### Flow Log Fields

The module captures all available fields by default:

- `version` - VPC Flow Logs version
- `resource-type` - The type of resource (TransitGateway)
- `account-id` - AWS account ID
- `tgw-id` - Transit Gateway ID
- `tgw-attachment-id` - Transit Gateway attachment ID
- `tgw-src-vpc-account-id` - Source VPC account ID
- `tgw-dst-vpc-account-id` - Destination VPC account ID
- `tgw-src-vpc-id` - Source VPC ID
- `tgw-dst-vpc-id` - Destination VPC ID
- `tgw-src-subnet-id` - Source subnet ID
- `tgw-dst-subnet-id` - Destination subnet ID
- `tgw-src-eni` - Source ENI
- `tgw-dst-eni` - Destination ENI
- `tgw-src-az-id` - Source Availability Zone ID
- `tgw-dst-az-id` - Destination Availability Zone ID
- `srcaddr` - Source IP address
- `dstaddr` - Destination IP address
- `srcport` - Source port
- `dstport` - Destination port
- `protocol` - IANA protocol number
- `packets` - Number of packets
- `bytes` - Number of bytes
- `start` - Start time
- `end` - End time
- `log-status` - Logging status (OK, NODATA, SKIPDATA)
- `type` - Type of traffic (IPv4, IPv6, EFA)
- `packets-lost-no-route` - Packets dropped due to no route
- `packets-lost-blackhole` - Packets dropped due to blackhole route
- `packets-lost-mtu-exceeded` - Packets dropped due to MTU exceeded
- `packets-lost-ttl-expired` - Packets dropped due to TTL expired

### CloudWatch Logs Insights Queries

The module provides example queries for analyzing flow logs:

```bash
# Top talkers
fields @timestamp, srcaddr, dstaddr, bytes
| stats sum(bytes) as total_bytes by srcaddr, dstaddr
| sort total_bytes desc
| limit 20

# Rejected traffic
fields @timestamp, srcaddr, dstaddr, srcport, dstport, protocol
| filter `log-status` = 'NODATA' or `packets-lost-no-route` > 0 or `packets-lost-blackhole` > 0
| sort @timestamp desc
| limit 100

# Inter-VPC traffic
fields @timestamp, `tgw-src-vpc-id`, `tgw-dst-vpc-id`, bytes, packets
| filter `tgw-src-vpc-id` != `tgw-dst-vpc-id`
| stats sum(bytes) as total_bytes, sum(packets) as total_packets by `tgw-src-vpc-id`, `tgw-dst-vpc-id`
| sort total_bytes desc
```

## CloudWatch Alarms

The module automatically creates CloudWatch alarms for:

1. **BytesIn**: Monitors incoming traffic volume
2. **BytesOut**: Monitors outgoing traffic volume
3. **PacketDropCountBlackhole**: Alerts on packets dropped due to blackhole routes
4. **PacketDropCountNoRoute**: Alerts on packets dropped due to missing routes

## Routing Scenarios

### Scenario 1: Default Route Table (Simple)

All VPC attachments automatically associate and propagate with the default route table.

```hcl
default_route_table_association = "enable"
default_route_table_propagation = "enable"
```

### Scenario 2: Isolated VPCs

VPCs can communicate through Transit Gateway but not directly with each other.

```hcl
default_route_table_association = "disable"
default_route_table_propagation = "disable"

# Create custom route tables and manually associate attachments
```

### Scenario 3: Centralized Inspection

Route all traffic through a security VPC with inspection appliances.

```hcl
vpc_attachments = {
  security-vpc = {
    vpc_id                 = "vpc-security"
    subnet_ids             = ["subnet-xxxxx"]
    appliance_mode_support = "enable"  # Enable for network appliances
  }
}
```

## Cost Estimation

### Transit Gateway Pricing

- **Hourly charge**: ~$0.05/hour (~$36/month)
- **Data processing**: $0.02/GB

### Flow Logs Pricing

- **CloudWatch Logs ingestion**: $0.50/GB
- **CloudWatch Logs storage**: $0.03/GB-month
- **S3 storage**: $0.023/GB-month (Standard)

### Example Monthly Costs

```
Transit Gateway (1 gateway):           $36.00
VPC Attachments (3 VPCs):             $108.00  ($36/VPC)
Data Processing (1 TB):               $20.00
Flow Logs (CloudWatch, 100 GB):       $53.00
CloudWatch Alarms (4 alarms):         $0.40
---------------------------------------------------
Total Estimate:                       ~$217/month
```

## Outputs

| Output | Description |
|--------|-------------|
| `transit_gateway_id` | Transit Gateway ID |
| `transit_gateway_arn` | Transit Gateway ARN |
| `vpc_attachment_ids` | Map of VPC attachment IDs |
| `flow_logs_log_group_name` | CloudWatch Log Group name |
| `cloudwatch_insights_query_*` | Sample queries for log analysis |
| `view_flow_logs_command` | AWS CLI command to view logs |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.6.0 |
| aws | ~> 5.0 |

## Best Practices

1. **Enable Flow Logs**: Always enable for traffic visibility and troubleshooting
2. **Use Custom Route Tables**: For production, disable default route tables and create custom ones
3. **Enable CloudWatch Alarms**: Set up SNS notifications for critical alerts
4. **Resource Sharing**: Use AWS RAM for multi-account deployments
5. **Retention Policy**: Set appropriate log retention (7-90 days for most use cases)
6. **Tagging**: Use consistent tags for cost allocation and resource management
7. **ASN Planning**: Use unique ASNs to avoid conflicts with on-premises networks
8. **Subnet Placement**: Use dedicated subnets for Transit Gateway attachments
9. **High Availability**: Attach to subnets in multiple Availability Zones

## Limitations

1. **Maximum Attachments**: 5,000 attachments per Transit Gateway
2. **Maximum Route Tables**: 20 route tables per Transit Gateway
3. **Maximum Routes**: 10,000 routes per route table
4. **Bandwidth**: Up to 50 Gbps per VPC attachment
5. **MTU**: Maximum 8500 bytes

## References

- [AWS Transit Gateway Documentation](https://docs.aws.amazon.com/vpc/latest/tgw/)
- [Transit Gateway Flow Logs](https://docs.aws.amazon.com/vpc/latest/tgw/tgw-flow-logs.html)
- [Transit Gateway Pricing](https://aws.amazon.com/transit-gateway/pricing/)
- [Transit Gateway Quotas](https://docs.aws.amazon.com/vpc/latest/tgw/transit-gateway-quotas.html)
