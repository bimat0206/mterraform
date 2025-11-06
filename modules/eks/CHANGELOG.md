# Changelog

All notable changes to the EKS module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-01-06

### Added
- Initial release of EKS module with comprehensive features
- EKS cluster with Kubernetes version support (default: 1.28)
- All 5 control plane log types enabled by default (api, audit, authenticator, controllerManager, scheduler)
- CloudWatch Logs integration for control plane logs
- OIDC provider for IAM Roles for Service Accounts (IRSA)
- Managed node groups with auto-scaling support
- Node group support for taints and labels
- Multiple capacity types (ON_DEMAND, SPOT)
- KMS encryption for Kubernetes secrets
- Security groups for cluster and nodes with automatic rules
- Public and private API endpoint support
- CIDR-based access control for public endpoint

### EKS Add-ons
- **VPC CNI**: AWS VPC networking for Kubernetes pods (enabled by default)
- **CoreDNS**: Kubernetes DNS service (enabled by default)
- **kube-proxy**: Kubernetes network proxy (enabled by default)
- **EBS CSI Driver**: Persistent volume support with IRSA (enabled by default)
- **AWS Load Balancer Controller**: ALB/NLB provisioning with comprehensive IAM policy (enabled by default)

### Monitoring and Observability
- CloudWatch Container Insights with 3 log groups:
  - `/aws/containerinsights/{cluster}/application` - Application logs
  - `/aws/containerinsights/{cluster}/performance` - Performance metrics
  - `/aws/containerinsights/{cluster}/dataplane` - Data plane logs
- Container Insights IAM role with CloudWatch permissions
- Configurable log retention (default: 7 days for cluster logs and Container Insights)
- CloudWatch Logs export for all control plane log types

### IAM and Access Management
- EKS Access Entries (modern replacement for aws-auth ConfigMap)
- IAM role mapping to Kubernetes RBAC groups
- IAM user mapping to Kubernetes RBAC groups
- IAM group mapping via auto-created assumable roles
- Cluster IAM role with EKS policies
- Node group IAM role with worker node, CNI, ECR, and SSM policies
- EBS CSI driver IAM role with service account integration
- AWS Load Balancer Controller IAM role with full provisioning permissions
- Container Insights IAM role for metrics and logs

### Security
- Separate security groups for cluster and nodes
- Automatic security group rules for cluster-node communication
- Additional security group rules support
- KMS encryption for secrets at rest
- Auto-created KMS key with rotation enabled
- Option to bring your own KMS key
- SSM access for nodes (no SSH required)
- Configurable endpoint access (public/private)

### Network Configuration
- VPC and subnet configuration
- Separate control plane subnet support
- Service IPv4 CIDR configuration
- IPv4/IPv6 dual-stack support
- Public access CIDR restrictions

### File Organization
- **data.tf**: Data sources and locals
- **cluster.tf**: EKS cluster and OIDC provider
- **iam_cluster.tf**: Cluster IAM configuration
- **iam_nodes.tf**: Node group IAM configuration
- **iam_addons.tf**: Add-on IAM configuration (EBS CSI, ALB Controller, Container Insights)
- **security_groups.tf**: Security group configuration
- **node_groups.tf**: Node group resources
- **addons.tf**: EKS add-on configuration
- **cloudwatch.tf**: CloudWatch log groups
- **access_entries.tf**: EKS Access Entries for IAM mapping
- **versions.tf**: Provider requirements
- **variables.tf**: Input variables (40+)
- **outputs.tf**: Output values (20+)

### Outputs
- Cluster information (ID, ARN, name, endpoint, version, status)
- OIDC provider details (ARN, URL)
- IAM role ARNs (cluster, node groups, add-ons)
- Security group IDs (cluster, nodes)
- Node group information (IDs, ARNs, status)
- Add-on versions (VPC CNI, CoreDNS, kube-proxy, EBS CSI, ALB Controller)
- CloudWatch log group names and ARNs
- Kubeconfig command
- kubectl configuration
- View logs commands
- Cluster management commands
- IAM role mapping information
- Container Insights setup commands
- Logging and add-on status

### Default Values
- Kubernetes version: `1.28`
- Control plane endpoint: Public and private enabled
- Public access CIDRs: `["0.0.0.0/0"]`
- All control plane log types enabled
- Cluster log retention: 7 days
- Container Insights: Enabled
- Container Insights log retention: 7 days
- Cluster encryption: Enabled
- IRSA: Enabled
- All add-ons: Enabled by default
- IP family: IPv4

### Features Summary
- **Complete Logging**: All 5 control plane log types + Container Insights
- **Full Add-on Support**: All essential EKS add-ons with IAM roles
- **Modern IAM Mapping**: EKS Access Entries instead of aws-auth ConfigMap
- **Production Ready**: Encryption, monitoring, and security best practices
- **Flexible**: Support for multiple node groups, taints, labels, and capacity types
- **Cost Optimized**: Support for Spot instances and configurable log retention
- **Highly Available**: Multi-AZ support and auto-scaling
- **Secure**: KMS encryption, security groups, IAM roles with least privilege
- **Observable**: CloudWatch Logs, Container Insights, and comprehensive outputs
- **Easy to Troubleshoot**: Organized file structure, comprehensive documentation

### Notes
- Minimum 2 subnets required in different availability zones
- EBS CSI driver requires IRSA to be enabled
- AWS Load Balancer Controller requires IRSA to be enabled
- Container Insights provides comprehensive monitoring without additional configuration
- Node group desired_size is ignored after initial creation (managed by auto-scaling)
- IAM group access requires users to assume the auto-created role
- EKS Access Entries replace the legacy aws-auth ConfigMap
- All add-ons use OVERWRITE conflict resolution on create, PRESERVE on update

### Breaking Changes from aws-auth ConfigMap
- This module uses EKS Access Entries (modern approach) instead of aws-auth ConfigMap
- IAM group mapping creates assumable roles instead of direct ConfigMap entries
- Users must use `aws sts assume-role` to access cluster via IAM groups
- No kubernetes provider required for IAM mapping

### Migration from aws-auth ConfigMap
If migrating from aws-auth ConfigMap:
1. Existing aws-auth ConfigMap entries must be migrated to EKS Access Entries
2. IAM principals will need to re-configure kubectl access
3. Use the provided IAM mapping variables to configure access

### Known Limitations
- IAM group members must assume role to access cluster (not direct access)
- Node group desired_size cannot be managed by Terraform after creation
- Add-on versions default to latest if not specified
- Container Insights requires CloudWatch agent deployment (see outputs for commands)

## [Unreleased]

### Planned
- Cluster autoscaler configuration
- Fargate profile support
- Pod identity associations
- Advanced networking (IPv6, prefix delegation)
- Blue/green deployment support
- Additional add-ons (EFS CSI driver, CloudWatch Observability)
