# AWS EKS Module

Terraform module for creating and managing AWS EKS (Elastic Kubernetes Service) clusters with comprehensive observability, security, and add-on support.

## Features

- **Complete Control Plane Logging**: All 5 log types enabled by default (api, audit, authenticator, controllerManager, scheduler)
- **EKS Add-ons**: VPC CNI, CoreDNS, kube-proxy, EBS CSI Driver, AWS Load Balancer Controller
- **Container Insights**: CloudWatch monitoring for containerized applications with 3 log groups
- **IRSA Support**: IAM Roles for Service Accounts via OIDC provider
- **IAM Access Management**: Modern EKS Access Entries for IAM to Kubernetes RBAC mapping
- **Managed Node Groups**: Auto-scaling node groups with taints and labels support
- **KMS Encryption**: Kubernetes secrets encryption at rest
- **Security Groups**: Automatic security group creation with customizable rules
- **Multi-AZ Support**: High availability across multiple availability zones
- **SSM Integration**: Systems Manager access for node management
- **Production Ready**: Best practices for security, logging, and monitoring

## Architecture

The module is organized into separate files for better maintainability:

- **data.tf**: Data sources and local variables
- **cluster.tf**: EKS cluster and OIDC provider
- **iam_cluster.tf**: Cluster IAM roles and policies
- **iam_nodes.tf**: Node group IAM roles and policies
- **iam_addons.tf**: Add-on IAM roles (EBS CSI, ALB Controller, Container Insights)
- **security_groups.tf**: Security groups for cluster and nodes
- **node_groups.tf**: EKS managed node groups
- **addons.tf**: EKS add-ons configuration
- **cloudwatch.tf**: CloudWatch log groups
- **access_entries.tf**: IAM to Kubernetes RBAC mapping
- **versions.tf**: Provider version constraints
- **variables.tf**: Input variables
- **outputs.tf**: Output values

## Usage

### Basic Example

```hcl
module "eks" {
  source = "../modules/eks"

  # Naming
  org_prefix  = "myorg"
  environment = "prod"
  workload    = "platform"
  identifier  = "01"

  # Network
  vpc_id     = "vpc-xxxxx"
  subnet_ids = ["subnet-xxxxx", "subnet-yyyyy", "subnet-zzzzz"]

  # Cluster
  kubernetes_version = "1.28"

  # Node Groups
  node_groups = {
    general = {
      instance_types = ["t3.xlarge"]
      desired_size   = 3
      min_size       = 2
      max_size       = 6
      capacity_type  = "ON_DEMAND"
      disk_size      = 50
      labels         = {}
      taints         = []
    }
  }

  tags = {
    Project = "Platform"
  }
}
```

### Advanced Example with Multiple Node Groups

```hcl
module "eks" {
  source = "../modules/eks"

  # Naming
  org_prefix  = "myorg"
  environment = "prod"
  workload    = "platform"
  service     = "k8s"
  identifier  = "01"

  # Network
  vpc_id                  = module.vpc.vpc_id
  subnet_ids              = module.vpc.private_subnet_ids
  control_plane_subnet_ids = module.vpc.private_subnet_ids

  # Cluster Configuration
  kubernetes_version               = "1.28"
  cluster_endpoint_public_access   = true
  cluster_endpoint_private_access  = true
  cluster_endpoint_public_access_cidrs = ["10.0.0.0/8"]

  # Encryption
  enable_cluster_encryption = true

  # Logging (all types enabled by default)
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  cluster_log_retention_days = 30

  # Node Groups
  node_groups = {
    # General purpose nodes
    general = {
      instance_types = ["t3.xlarge"]
      desired_size   = 3
      min_size       = 2
      max_size       = 10
      capacity_type  = "ON_DEMAND"
      disk_size      = 100
      labels = {
        role = "general"
      }
      taints = []
    }

    # Compute-intensive nodes
    compute = {
      instance_types = ["c6i.2xlarge"]
      desired_size   = 2
      min_size       = 1
      max_size       = 5
      capacity_type  = "ON_DEMAND"
      disk_size      = 100
      labels = {
        role = "compute"
      }
      taints = [
        {
          key    = "workload"
          value  = "compute"
          effect = "NoSchedule"
        }
      ]
    }

    # Spot instances for batch workloads
    spot = {
      instance_types = ["t3.large", "t3a.large"]
      desired_size   = 2
      min_size       = 0
      max_size       = 10
      capacity_type  = "SPOT"
      disk_size      = 50
      labels = {
        role = "spot"
      }
      taints = [
        {
          key    = "spot"
          value  = "true"
          effect = "NoSchedule"
        }
      ]
    }
  }

  # Add-ons (all enabled by default)
  enable_vpc_cni_addon                 = true
  enable_coredns_addon                 = true
  enable_kube_proxy_addon              = true
  enable_ebs_csi_driver_addon          = true
  enable_aws_load_balancer_controller  = true

  # IRSA (required for add-ons)
  enable_irsa = true

  # Container Insights
  enable_container_insights           = true
  container_insights_log_retention_days = 7

  # IAM Mapping - Roles
  aws_auth_roles = [
    {
      rolearn  = "arn:aws:iam::123456789012:role/DevOps"
      username = "devops"
      groups   = ["system:masters"]
    }
  ]

  # IAM Mapping - Users
  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::123456789012:user/admin"
      username = "admin"
      groups   = ["system:masters"]
    }
  ]

  # IAM Mapping - Groups
  map_iam_groups = {
    developers = {
      iam_group_arn = "arn:aws:iam::123456789012:group/Developers"
      k8s_groups    = ["developers"]
      k8s_username  = "{{SessionName}}"
    }
    readonly = {
      iam_group_arn = "arn:aws:iam::123456789012:group/ReadOnly"
      k8s_groups    = ["view-only"]
    }
  }

  tags = {
    Project     = "Platform"
    CostCenter  = "Engineering"
    Compliance  = "SOC2"
  }
}
```

## Control Plane Logging

The module enables all 5 EKS control plane log types by default:

1. **api**: API server logs
2. **audit**: Kubernetes audit logs
3. **authenticator**: Authentication logs
4. **controllerManager**: Controller manager logs
5. **scheduler**: Scheduler logs

All logs are exported to CloudWatch Logs with configurable retention (default: 7 days).

### View Cluster Logs

```bash
# View logs
aws logs tail /aws/eks/myorg-prod-platform-eks-01/cluster --follow --format short

# Query specific log types
aws logs filter-log-events \
  --log-group-name /aws/eks/myorg-prod-platform-eks-01/cluster \
  --filter-pattern "error"
```

## EKS Add-ons

### VPC CNI
AWS VPC networking for Kubernetes pods. Enabled by default.

### CoreDNS
Kubernetes DNS service. Enabled by default.

### kube-proxy
Kubernetes network proxy. Enabled by default.

### EBS CSI Driver
Persistent volume support using Amazon EBS. Enabled by default with IRSA.

**Features:**
- Dynamic volume provisioning
- Volume snapshots
- Volume resizing
- IAM role for service account (IRSA)

**Usage:**
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ebs-claim
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: gp3
  resources:
    requests:
      storage: 10Gi
```

### AWS Load Balancer Controller
Provisions Application Load Balancers (ALB) and Network Load Balancers (NLB) for Kubernetes services.

**Features:**
- Automatic ALB/NLB provisioning
- Kubernetes Ingress support
- Service annotations for advanced configuration
- IAM role with comprehensive permissions

**Usage:**
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress
  annotations:
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
spec:
  ingressClassName: alb
  rules:
    - host: app.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: app-service
                port:
                  number: 80
```

## Container Insights

CloudWatch Container Insights provides comprehensive monitoring for containerized applications.

**Log Groups:**
- `/aws/containerinsights/{cluster-name}/application` - Application logs
- `/aws/containerinsights/{cluster-name}/performance` - Performance metrics
- `/aws/containerinsights/{cluster-name}/dataplane` - Data plane logs

**View Container Insights:**
```bash
# Application logs
aws logs tail /aws/containerinsights/myorg-prod-platform-eks-01/application --follow

# Performance metrics
aws logs tail /aws/containerinsights/myorg-prod-platform-eks-01/performance --follow
```

## IAM to Kubernetes RBAC Mapping

The module uses modern **EKS Access Entries** (replacement for aws-auth ConfigMap) to map IAM principals to Kubernetes RBAC.

### IAM Roles

Map IAM roles directly to Kubernetes groups:

```hcl
aws_auth_roles = [
  {
    rolearn  = "arn:aws:iam::123456789012:role/DevOps"
    username = "devops"
    groups   = ["system:masters"]
  }
]
```

### IAM Users

Map IAM users directly to Kubernetes groups:

```hcl
aws_auth_users = [
  {
    userarn  = "arn:aws:iam::123456789012:user/admin"
    username = "admin"
    groups   = ["system:masters"]
  }
]
```

### IAM Groups

Map IAM groups via auto-created assumable roles:

```hcl
map_iam_groups = {
  developers = {
    iam_group_arn = "arn:aws:iam::123456789012:group/Developers"
    k8s_groups    = ["developers", "view"]
    k8s_username  = "{{SessionName}}"
  }
}
```

**How it works:**
1. Module creates an IAM role that can be assumed by the IAM group
2. EKS Access Entry maps the role to Kubernetes groups
3. Users in the IAM group assume the role to access the cluster

### Common Kubernetes Groups

- `system:masters` - Full cluster admin access
- `system:bootstrappers` - Bootstrap new nodes
- `system:nodes` - Node access
- `view` - Read-only cluster-wide access
- `edit` - Namespace-level edit access
- `admin` - Namespace-level admin access

### Create Custom RBAC

```yaml
# Create a developers ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: developers
rules:
  - apiGroups: ["", "apps", "batch"]
    resources: ["*"]
    verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]

---
# Bind to the developers group
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: developers
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: developers
subjects:
  - kind: Group
    name: developers
```

## Accessing the Cluster

### Configure kubectl

```bash
# Update kubeconfig
aws eks update-kubeconfig --region us-east-1 --name myorg-prod-platform-eks-01

# Verify access
kubectl get nodes
kubectl get pods --all-namespaces
```

### Assume Role (for IAM Group access)

```bash
# Assume the role created for your IAM group
aws sts assume-role \
  --role-arn arn:aws:iam::123456789012:role/myorg-prod-platform-eks-01-developers-access-role \
  --role-session-name my-session

# Configure kubectl with assumed role credentials
export AWS_ACCESS_KEY_ID=<access-key>
export AWS_SECRET_ACCESS_KEY=<secret-key>
export AWS_SESSION_TOKEN=<session-token>

aws eks update-kubeconfig --region us-east-1 --name myorg-prod-platform-eks-01
```

## Node Groups

Node groups are managed auto-scaling groups of EC2 instances.

### Capacity Types

- **ON_DEMAND**: Standard on-demand instances (default)
- **SPOT**: Spot instances for cost savings (up to 90% cheaper)

### Taints and Tolerations

Use taints to dedicate nodes to specific workloads:

```hcl
node_groups = {
  gpu = {
    instance_types = ["g4dn.xlarge"]
    desired_size   = 2
    min_size       = 1
    max_size       = 4
    capacity_type  = "ON_DEMAND"
    disk_size      = 100
    labels = {
      workload = "gpu"
    }
    taints = [
      {
        key    = "nvidia.com/gpu"
        value  = "true"
        effect = "NoSchedule"
      }
    ]
  }
}
```

Then in your pod spec:
```yaml
tolerations:
  - key: "nvidia.com/gpu"
    operator: "Equal"
    value: "true"
    effect: "NoSchedule"
```

### Instance Types

Choose instance types based on your workload:

- **General Purpose**: t3.medium, t3.large, t3.xlarge, m6i.large, m6i.xlarge
- **Compute Optimized**: c6i.large, c6i.xlarge, c6i.2xlarge
- **Memory Optimized**: r6i.large, r6i.xlarge, r6i.2xlarge
- **GPU**: g4dn.xlarge, g4dn.2xlarge, p3.2xlarge

## Security

### Network Security

- Separate security groups for cluster and nodes
- Cluster endpoint can be public, private, or both
- Public endpoint CIDR restrictions
- Automatic security group rules for cluster-node communication

### Encryption

- Kubernetes secrets encrypted at rest using KMS
- Auto-created KMS key or bring your own
- EBS volumes encrypted by default

### IAM

- Least privilege IAM roles
- IRSA for pod-level IAM permissions
- SSM access for node troubleshooting (no SSH required)

## Monitoring and Observability

### CloudWatch Logs

- **Control Plane Logs**: All 5 log types in `/aws/eks/{cluster-name}/cluster`
- **Container Insights**: Application, performance, and dataplane logs

### CloudWatch Metrics

Container Insights provides:
- Pod CPU and memory utilization
- Node CPU and memory utilization
- Network metrics
- Disk utilization
- Container restart counts

### Prometheus (Optional)

Deploy Prometheus for advanced monitoring:

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/kube-prometheus-stack
```

## Troubleshooting

### View Cluster Status

```bash
# Describe cluster
aws eks describe-cluster --name myorg-prod-platform-eks-01 --region us-east-1

# List node groups
aws eks list-nodegroups --cluster-name myorg-prod-platform-eks-01 --region us-east-1

# Describe node group
aws eks describe-nodegroup --cluster-name myorg-prod-platform-eks-01 --nodegroup-name general
```

### View Add-on Status

```bash
# List add-ons
aws eks list-addons --cluster-name myorg-prod-platform-eks-01 --region us-east-1

# Describe add-on
aws eks describe-addon --cluster-name myorg-prod-platform-eks-01 --addon-name vpc-cni
```

### Connect to Node (SSM)

```bash
# List nodes
kubectl get nodes

# Start SSM session
aws ssm start-session --target <instance-id>
```

### Common Issues

**Pods not starting:**
```bash
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

**Node not joining:**
```bash
# Check node group status
aws eks describe-nodegroup --cluster-name myorg-prod-platform-eks-01 --nodegroup-name general

# View kubelet logs on node
journalctl -u kubelet -f
```

**Load Balancer not provisioning:**
```bash
# Check AWS Load Balancer Controller logs
kubectl logs -n kube-system deployment/aws-load-balancer-controller

# Verify IAM role
kubectl describe sa -n kube-system aws-load-balancer-controller
```

## Cost Optimization

1. **Use Spot Instances**: Up to 90% savings for fault-tolerant workloads
2. **Right-size Nodes**: Start small and scale up based on metrics
3. **Enable Cluster Autoscaler**: Automatically scale node groups based on demand
4. **Use Fargate**: Serverless compute for specific workloads (requires separate configuration)
5. **Reduce Log Retention**: Lower retention days for non-production environments

## Outputs

| Output | Description |
|--------|-------------|
| `cluster_id` | EKS cluster ID/name |
| `cluster_endpoint` | Kubernetes API endpoint |
| `cluster_certificate_authority_data` | Cluster CA certificate (sensitive) |
| `oidc_provider_arn` | OIDC provider ARN for IRSA |
| `cluster_security_group_id` | Cluster security group ID |
| `node_security_group_id` | Node security group ID |
| `node_group_ids` | Map of node group IDs |
| `kubeconfig_command` | Command to configure kubectl |
| `cluster_log_group_name` | CloudWatch log group name |
| `container_insights_log_group_names` | Container Insights log group names |
| `ebs_csi_driver_iam_role_arn` | EBS CSI driver IAM role ARN |
| `aws_load_balancer_controller_iam_role_arn` | ALB controller IAM role ARN |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.6.0 |
| aws | ~> 5.0 |
| tls | ~> 4.0 |

## Version History

See [CHANGELOG.md](./CHANGELOG.md) for version history.

## References

- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/latest/userguide/)
- [EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)
- [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/)
- [Container Insights](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/ContainerInsights.html)
- [EKS Access Entries](https://docs.aws.amazon.com/eks/latest/userguide/access-entries.html)
