# Changelog

All notable changes to the Transit Gateway module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-01-06

### Added
- Initial release of Transit Gateway module
- Transit Gateway resource with comprehensive configuration options
- Dynamic naming convention: {org_prefix}-{environment}-{workload}-{service}-{identifier}
- VPC attachments with support for multiple VPCs
- Custom Transit Gateway route tables
- Flow Logs with CloudWatch Logs or S3 destination
- Complete flow log format with all 28 available fields
- CloudWatch Log Group with configurable retention (0-3653 days)
- IAM role for CloudWatch Logs flow logs delivery
- CloudWatch alarms for traffic monitoring:
  - BytesIn alarm for incoming traffic
  - BytesOut alarm for outgoing traffic
  - PacketDropCountBlackhole alarm for blackhole route drops
  - PacketDropCountNoRoute alarm for no route drops
- AWS RAM resource sharing for multi-account deployments
- BGP ASN configuration (64512-65534 or 4200000000-4294967294)
- DNS support for name resolution across VPCs
- VPN ECMP support for equal cost multipath routing
- Multicast support option
- IPv6 support for VPC attachments
- Appliance mode support for network appliances
- Configurable route table association and propagation
- Auto-accept shared attachments option
- Transit Gateway CIDR blocks configuration
- Comprehensive tagging support

### Flow Logs Features
- All 28 flow log fields captured by default
- CloudWatch Logs or S3 destination support
- Configurable aggregation interval (60 or 600 seconds)
- Custom log format support
- CloudWatch Logs retention policies
- IAM role auto-creation for CloudWatch Logs

### CloudWatch Monitoring
- 4 pre-configured CloudWatch alarms
- SNS topic integration for alarm notifications
- Configurable thresholds for all alarms
- Traffic volume monitoring (BytesIn, BytesOut)
- Packet drop monitoring (Blackhole, NoRoute)

### Outputs
- Transit Gateway ID, ARN, and name
- Default route table IDs (association and propagation)
- VPC attachment IDs and VPC mappings
- Custom route table IDs and ARNs
- Flow Logs ID and CloudWatch Log Group details
- CloudWatch alarm ARNs
- RAM resource share details
- CloudWatch Logs Insights query examples
- AWS CLI commands for management and monitoring

### CloudWatch Logs Insights Queries
- Top talkers query for identifying high-traffic sources
- Rejected traffic query for troubleshooting dropped packets
- Inter-VPC traffic analysis query

### Resource Sharing
- AWS RAM integration for multi-account access
- Support for Organization-wide sharing
- Support for specific account sharing
- External principal support option

### Configuration Options
- Configurable ASN for BGP sessions
- Route table association/propagation controls
- DNS and VPN ECMP support toggles
- Multicast support option
- Custom flow log format
- Flexible VPC attachment configuration

### Default Values
- Amazon Side ASN: 64512
- Auto-accept shared attachments: disabled
- Default route table association: enabled
- Default route table propagation: enabled
- DNS support: enabled
- VPN ECMP support: enabled
- Multicast support: disabled
- Flow logs: enabled
- Flow logs destination: CloudWatch Logs
- Flow logs retention: 7 days
- CloudWatch alarms: enabled
- Resource sharing: disabled

### Supported Use Cases
- Hub-and-spoke architecture
- Multi-account connectivity
- Hybrid cloud connections (VPN/Direct Connect)
- Network segmentation with custom route tables
- Centralized traffic inspection
- High-availability network topologies

### Cost Optimization
- Configurable flow log retention
- Optional CloudWatch alarms
- S3 destination option for cost-effective log storage
- Resource sharing to reduce redundant Transit Gateways

### Notes
- Maximum 5,000 attachments per Transit Gateway
- Maximum 20 custom route tables per Transit Gateway
- Maximum 10,000 routes per route table
- Up to 50 Gbps bandwidth per VPC attachment
- Maximum MTU of 8500 bytes
- Flow logs require IAM role for CloudWatch Logs destination
- Resource sharing requires AWS RAM service
