# EC2 Key Pair Module

Terraform module for generating EC2 key pairs and securely storing private keys in AWS Secrets Manager. This module automates key pair creation and eliminates the need for manual key management.

## Features

- **Automatic Key Generation**: Creates RSA, ECDSA, or ED25519 key pairs using TLS provider
- **EC2 Integration**: Automatically creates AWS EC2 key pairs
- **Secrets Manager**: Securely stores private keys in AWS Secrets Manager
- **Multiple Algorithms**: Support for RSA (2048/4096), ECDSA (P224/P256/P384/P521), ED25519
- **Secret Rotation**: Optional automatic secret rotation
- **KMS Encryption**: Optional custom KMS key for secret encryption
- **Dynamic Naming**: Consistent resource naming based on organizational standards
- **Local Files**: Optional local key file creation (not recommended for production)
- **Comprehensive Outputs**: Key pair details, secret ARNs, and usage commands

## Security Benefits

✅ **No Manual Key Management**: Keys never exist on developer machines
✅ **Centralized Storage**: Private keys securely stored in Secrets Manager
✅ **Access Control**: Fine-grained IAM permissions for key access
✅ **Audit Trail**: CloudTrail logs all secret access
✅ **Encryption**: Keys encrypted at rest with KMS
✅ **Automatic Rotation**: Optional periodic key rotation
✅ **Recovery Window**: Configurable deletion protection

## Cost Information

**AWS Secrets Manager:**
- Storage: $0.40 per secret per month
- API Calls: $0.05 per 10,000 API calls
- **Example**: 2 secrets (Linux + Windows) = ~$0.80/month

**KMS (if using customer-managed key):**
- Key: $1.00 per month
- API Calls: $0.03 per 10,000 requests

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.6.0 |
| aws | ~> 5.0 |
| tls | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 5.0 |
| tls | ~> 4.0 |

## Resources

| Name | Type |
|------|------|
| tls_private_key.this | resource |
| aws_key_pair.this | resource |
| aws_secretsmanager_secret.private_key | resource |
| aws_secretsmanager_secret_version.private_key | resource |
| aws_secretsmanager_secret_rotation.private_key | resource |
| local_file.public_key | resource |
| local_file.private_key | resource |
| aws_region.current | data source |

## Usage Examples

### Basic Key Pair with Secrets Manager

```hcl
module "keypair_linux" {
  source = "../modules/keypair"

  # Naming
  org_prefix  = "tsk"
  environment = "prod"
  workload    = "app"
  service     = "linux"
  identifier  = "01"

  # Key Configuration
  algorithm = "RSA"
  rsa_bits  = 4096

  # Secrets Manager (enabled by default)
  create_secret                 = true
  secret_recovery_window_in_days = 30

  tags = {}
}

# Use the key pair in EC2 instance
module "ec2_linux" {
  source = "../modules/ec2-linux"

  key_name = module.keypair_linux.key_pair_name
  # ... other configuration
}
```

### Multiple Key Pairs (Linux and Windows)

```hcl
module "keypair_linux" {
  source = "../modules/keypair"

  org_prefix  = "tsk"
  environment = "prod"
  workload    = "app"
  service     = "linux"

  algorithm = "RSA"
  rsa_bits  = 4096

  tags = {}
}

module "keypair_windows" {
  source = "../modules/keypair"

  org_prefix  = "tsk"
  environment = "prod"
  workload    = "app"
  service     = "windows"

  algorithm = "RSA"
  rsa_bits  = 4096

  tags = {}
}

# Use in EC2 instances
module "ec2_linux" {
  source   = "../modules/ec2-linux"
  key_name = module.keypair_linux.key_pair_name
  # ...
}

module "ec2_windows" {
  source   = "../modules/ec2-windows"
  key_name = module.keypair_windows.key_pair_name
  # ...
}
```

### Key Pair with Custom KMS Encryption

```hcl
module "keypair" {
  source = "../modules/keypair"

  org_prefix  = "tsk"
  environment = "prod"
  workload    = "app"

  # Secrets Manager with custom KMS key
  create_secret   = true
  secret_kms_key_id = "arn:aws:kms:region:account:key/12345678-1234-1234-1234-123456789012"

  tags = {}
}
```

### ECDSA Key Pair

```hcl
module "keypair_ecdsa" {
  source = "../modules/keypair"

  org_prefix  = "tsk"
  environment = "dev"
  workload    = "test"

  algorithm   = "ECDSA"
  ecdsa_curve = "P384"

  tags = {}
}
```

### ED25519 Key Pair (Modern, Secure)

```hcl
module "keypair_ed25519" {
  source = "../modules/keypair"

  org_prefix  = "tsk"
  environment = "prod"
  workload    = "app"

  algorithm = "ED25519"  # Most secure, smallest keys

  tags = {}
}
```

### Key Pair with Local File (Development Only)

```hcl
module "keypair_dev" {
  source = "../modules/keypair"

  org_prefix  = "tsk"
  environment = "dev"
  workload    = "test"

  # Create local files (NOT RECOMMENDED for production)
  create_public_key_file  = true
  create_private_key_file = true
  file_permission         = "0400"

  # Still store in Secrets Manager
  create_secret = true

  tags = {}
}
```

### Custom Key Pair Name

```hcl
module "keypair_custom" {
  source = "../modules/keypair"

  org_prefix  = "tsk"
  environment = "prod"
  workload    = "app"

  # Custom key pair name
  key_name    = "my-custom-keypair-name"
  secret_name = "my-custom-keypair-secret"

  tags = {}
}
```

## Retrieving Private Keys

### From Secrets Manager (Recommended)

```bash
# Get the private key from Secrets Manager
aws secretsmanager get-secret-value \
  --secret-id tsk-prod-app-linux-01-private-key \
  --query SecretString --output text | \
  jq -r '.private_key' > keypair.pem

# Set proper permissions
chmod 400 keypair.pem

# Use for SSH
ssh -i keypair.pem ec2-user@<instance-ip>
```

### From Terraform Output (Temporary)

```bash
# Extract private key from terraform output (for testing only)
terraform output -raw private_key_pem > keypair.pem
chmod 400 keypair.pem
```

### Decrypt Windows Password

```bash
# Get private key from Secrets Manager and decrypt Windows password
aws secretsmanager get-secret-value \
  --secret-id tsk-prod-app-windows-01-private-key \
  --query SecretString --output text | \
  jq -r '.private_key' > /tmp/keypair.pem

# Get and decrypt Windows password
aws ec2 get-password-data \
  --instance-id i-0123456789abcdef \
  --priv-launch-key /tmp/keypair.pem

# Clean up
rm /tmp/keypair.pem
```

## Secret Structure

The secret stored in Secrets Manager contains:

```json
{
  "key_name": "tsk-prod-app-linux-01",
  "key_pair_id": "key-0123456789abcdef",
  "algorithm": "RSA",
  "private_key": "-----BEGIN RSA PRIVATE KEY-----\n...\n-----END RSA PRIVATE KEY-----",
  "public_key": "ssh-rsa AAAAB3NzaC1...",
  "fingerprint": "ab:cd:ef:12:34:56:78:90",
  "created_at": "2025-11-06T12:00:00Z"
}
```

## Variables

### Naming Convention

| Name | Type | Default | Description |
|------|------|---------|-------------|
| org_prefix | string | - | Organization prefix |
| environment | string | - | Environment name |
| workload | string | - | Workload name |
| service | string | "" | Service name (defaults to 'keypair') |
| identifier | string | "" | Resource identifier |

### Key Pair Configuration

| Name | Type | Default | Description |
|------|------|---------|-------------|
| key_name | string | "" | Custom key pair name (auto-generated if empty) |
| algorithm | string | "RSA" | Algorithm: RSA, ECDSA, ED25519 |
| rsa_bits | number | 4096 | RSA key size: 2048 or 4096 |
| ecdsa_curve | string | "P384" | ECDSA curve: P224, P256, P384, P521 |

### Secrets Manager Configuration

| Name | Type | Default | Description |
|------|------|---------|-------------|
| create_secret | bool | true | Store private key in Secrets Manager |
| secret_name | string | "" | Custom secret name (auto-generated if empty) |
| secret_recovery_window_in_days | number | 30 | Days to retain deleted secret (7-30) |
| secret_kms_key_id | string | "" | Custom KMS key ID |
| enable_secret_rotation | bool | false | Enable automatic rotation |

### File Configuration

| Name | Type | Default | Description |
|------|------|---------|-------------|
| create_public_key_file | bool | false | Create local public key file |
| create_private_key_file | bool | false | Create local private key file (NOT RECOMMENDED) |
| file_permission | string | "0400" | File permissions |

## Outputs

### Key Pair Outputs

| Name | Description |
|------|-------------|
| key_pair_name | EC2 key pair name |
| key_pair_id | EC2 key pair ID |
| key_pair_arn | EC2 key pair ARN |
| key_pair_fingerprint | MD5 fingerprint |

### Public Key Outputs

| Name | Description |
|------|-------------|
| public_key_openssh | Public key (OpenSSH format) |
| public_key_pem | Public key (PEM format) |
| public_key_fingerprint_md5 | MD5 fingerprint |
| public_key_fingerprint_sha256 | SHA256 fingerprint |

### Private Key Outputs (Sensitive)

| Name | Description |
|------|-------------|
| private_key_pem | Private key PEM (sensitive) |
| private_key_openssh | Private key OpenSSH (sensitive) |

### Secrets Manager Outputs

| Name | Description |
|------|-------------|
| secret_id | Secrets Manager secret ID |
| secret_arn | Secrets Manager secret ARN |
| secret_name | Secrets Manager secret name |
| secret_version_id | Secret version ID |

### Usage Instructions

| Name | Description |
|------|-------------|
| ssh_usage_command | Example SSH command |
| retrieve_secret_command | AWS CLI command to retrieve key |
| decrypt_windows_password_command | Command to decrypt Windows password |

## Algorithm Comparison

| Algorithm | Key Size | Security | Performance | EC2 Support | Recommended |
|-----------|----------|----------|-------------|-------------|-------------|
| RSA 4096 | 4096 bits | Excellent | Good | ✅ Yes | ✅ Production |
| RSA 2048 | 2048 bits | Good | Better | ✅ Yes | ⚠️ Legacy |
| ECDSA P384 | ~384 bits | Excellent | Excellent | ✅ Yes | ✅ Modern |
| ECDSA P256 | ~256 bits | Good | Excellent | ✅ Yes | ✅ Modern |
| ED25519 | 256 bits | Excellent | Best | ✅ Yes | ✅ Most Secure |

**Recommendation**: Use **RSA 4096** for compatibility or **ED25519** for best security and performance.

## IAM Permissions

### Required for Module

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateKeyPair",
        "ec2:DeleteKeyPair",
        "ec2:DescribeKeyPairs"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:CreateSecret",
        "secretsmanager:DeleteSecret",
        "secretsmanager:DescribeSecret",
        "secretsmanager:PutSecretValue",
        "secretsmanager:TagResource"
      ],
      "Resource": "arn:aws:secretsmanager:*:*:secret:*"
    }
  ]
}
```

### Required for Key Retrieval

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue"
      ],
      "Resource": "arn:aws:secretsmanager:*:*:secret:*-private-key-*"
    }
  ]
}
```

## Security Best Practices

1. **Never Create Local Files in Production**: Use Secrets Manager only
2. **Use KMS Customer-Managed Keys**: For additional encryption control
3. **Restrict Secret Access**: Grant GetSecretValue only to necessary IAM roles
4. **Enable CloudTrail**: Monitor all secret access
5. **Use Strong Algorithms**: Prefer RSA 4096 or ED25519
6. **Rotate Keys Periodically**: Implement key rotation strategy
7. **Set Recovery Window**: Configure appropriate deletion protection
8. **Tag Secrets**: Use tags for cost allocation and access control
9. **Audit Regularly**: Review who has access to secrets
10. **Use IAM Conditions**: Restrict access by source IP, VPC, etc.

## Troubleshooting

### Cannot retrieve secret

**Problem**: `aws secretsmanager get-secret-value` fails

**Solutions**:
1. Verify IAM permissions include `secretsmanager:GetSecretValue`
2. Check secret name is correct
3. Ensure secret is in the same region
4. Verify VPC endpoints if using private subnets

### SSH connection fails with key

**Problem**: SSH refuses the private key

**Solutions**:
1. Verify file permissions: `chmod 400 keypair.pem`
2. Check key format (should be PEM)
3. Ensure correct username (ec2-user, ubuntu, etc.)
4. Verify key pair name matches instance

### Windows password decryption fails

**Problem**: Cannot decrypt Windows password

**Solutions**:
1. Wait 3-5 minutes after instance launch
2. Verify key pair was specified at instance launch
3. Check private key format
4. Ensure password data is available: `aws ec2 get-password-data --instance-id <id>`

## Secret Rotation

Enable automatic secret rotation (requires Lambda function):

```hcl
module "keypair" {
  source = "../modules/keypair"

  org_prefix  = "tsk"
  environment = "prod"
  workload    = "app"

  enable_secret_rotation      = true
  secret_rotation_lambda_arn  = "arn:aws:lambda:region:account:function:rotate-keypair"
  secret_rotation_days        = 90

  tags = {}
}
```

**Note**: You must create the Lambda rotation function separately.

## Migration from Existing Keys

To migrate existing manually-created key pairs:

1. Create new key pair with this module
2. Update EC2 instances to use new key pair
3. Test SSH/RDP access with new key
4. Delete old key pair
5. Remove old `.pem` files

## Comparison with Manual Key Pairs

| Feature | Manual | This Module |
|---------|--------|-------------|
| Key Generation | Manual | ✅ Automatic |
| Storage | Local file | ✅ Secrets Manager |
| Encryption | File permissions | ✅ KMS |
| Access Control | File ownership | ✅ IAM policies |
| Audit Trail | None | ✅ CloudTrail |
| Rotation | Manual | ✅ Automatic (optional) |
| Recovery | Risky | ✅ Recovery window |
| Team Access | File sharing | ✅ IAM permissions |

## Related Modules

- `../ec2-linux/` - Linux EC2 instances
- `../ec2-windows/` - Windows EC2 instances

## License

This module is provided as-is for use within your organization.
