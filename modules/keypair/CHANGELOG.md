# Changelog - Key Pair Module

All notable changes to the Key Pair module will be documented in this file.

## [1.0.0] - 2025-11-06

### Added
- Initial release of EC2 Key Pair module
- Automatic key pair generation using TLS provider
- Support for RSA (2048/4096 bits), ECDSA (P224/P256/P384/P521), and ED25519 algorithms
- AWS EC2 key pair creation
- AWS Secrets Manager integration for secure private key storage
- Secret stored in JSON format with key metadata (key_name, algorithm, fingerprint, timestamps)
- Optional KMS encryption for secrets
- Optional secret rotation support
- Configurable secret recovery window (7-30 days)
- Optional local file creation for public/private keys
- Dynamic naming based on organizational standards
- Comprehensive outputs (key pair details, secret ARNs, usage commands)
- Detailed documentation with security best practices

### Features
- **Automatic Key Generation**: No manual key management required
  - RSA 4096-bit (default) for maximum compatibility
  - RSA 2048-bit for legacy systems
  - ECDSA P224/P256/P384/P521 for modern security
  - ED25519 for best security and performance

- **Secrets Manager Integration**: Secure key storage
  - Private key stored in AWS Secrets Manager
  - JSON format with metadata (algorithm, fingerprint, timestamps)
  - Optional custom KMS key encryption
  - Configurable recovery window (30 days default)
  - Optional automatic rotation

- **Security**: Production-ready security
  - Keys never stored on local machines (production mode)
  - IAM-based access control
  - CloudTrail audit logging
  - KMS encryption at rest
  - Deletion protection with recovery window

- **Flexibility**: Multiple deployment options
  - Optional local file creation (development only)
  - Custom key pair names
  - Custom secret names
  - Configurable file permissions

- **Integration**: Easy EC2 integration
  - Compatible with ec2-linux module
  - Compatible with ec2-windows module
  - Direct output of key_pair_name for EC2 instances

### Cost Information
- **Secrets Manager**: $0.40 per secret per month
- **KMS (customer-managed)**: $1.00 per month (optional)
- **API Calls**: $0.05 per 10,000 calls
- **Example**: 2 key pairs (Linux + Windows) = ~$0.80/month

### Requirements
- Terraform >= 1.6.0
- AWS Provider ~> 5.0
- TLS Provider ~> 4.0
- IAM permissions for EC2 key pairs and Secrets Manager

### Use Cases
- Automated EC2 instance deployments
- Multi-environment key pair management
- Team-based key access control
- Centralized key storage and rotation
- Compliance and audit requirements
- SSH and RDP access to EC2 instances

### Default Configuration
- **Algorithm**: RSA 4096-bit
- **Secrets Manager**: Enabled (create_secret = true)
- **Recovery Window**: 30 days
- **KMS Encryption**: AWS managed key
- **Local Files**: Disabled (create_*_file = false)
- **Rotation**: Disabled (requires Lambda function)

### Security Considerations
- Private keys are stored in Secrets Manager by default
- Local file creation is disabled by default (not recommended for production)
- IAM permissions control access to secrets
- CloudTrail logs all secret access attempts
- KMS encryption protects keys at rest
- Recovery window prevents accidental deletion
- Sensitive outputs are marked as sensitive in Terraform

### Algorithm Recommendations
- **RSA 4096**: Best for compatibility with all systems
- **ED25519**: Best for security and performance (modern)
- **ECDSA P384**: Good balance of security and compatibility
- **RSA 2048**: Legacy systems only (less secure)

### Example Configurations

**Basic Linux Key Pair:**
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
```

**Windows Key Pair:**
```hcl
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
```

**Modern ED25519 Key:**
```hcl
module "keypair_modern" {
  source = "../modules/keypair"

  org_prefix  = "tsk"
  environment = "prod"
  workload    = "secure"

  algorithm = "ED25519"  # Most secure

  tags = {}
}
```

**With Custom KMS:**
```hcl
module "keypair_kms" {
  source = "../modules/keypair"

  org_prefix  = "tsk"
  environment = "prod"
  workload    = "app"

  secret_kms_key_id = "arn:aws:kms:region:account:key/12345678-..."

  tags = {}
}
```

### Integration with EC2 Modules

```hcl
# Create key pair
module "keypair" {
  source = "../modules/keypair"

  org_prefix  = "tsk"
  environment = "prod"
  workload    = "app"

  tags = {}
}

# Use in EC2 Linux instance
module "ec2_linux" {
  source = "../modules/ec2-linux"

  key_name = module.keypair.key_pair_name  # Direct integration
  # ... other config
}
```

### Retrieving Private Keys

**From Secrets Manager (Recommended):**
```bash
# Retrieve private key
aws secretsmanager get-secret-value \
  --secret-id tsk-prod-app-linux-01-private-key \
  --query SecretString --output text | \
  jq -r '.private_key' > keypair.pem

chmod 400 keypair.pem
```

**For Windows Password Decryption:**
```bash
# Get private key and decrypt Windows password
aws secretsmanager get-secret-value \
  --secret-id tsk-prod-app-windows-01-private-key \
  --query SecretString --output text | \
  jq -r '.private_key' > /tmp/key.pem

aws ec2 get-password-data \
  --instance-id i-xxx \
  --priv-launch-key /tmp/key.pem

rm /tmp/key.pem
```

### Documentation
- Comprehensive README with usage examples
- Multiple deployment scenarios
- Security best practices
- IAM permission requirements
- Algorithm comparison table
- Troubleshooting guide
- Migration guide from manual keys
- Secret structure documentation

### Outputs
- **Key Pair**: name, ID, ARN, fingerprint
- **Public Key**: OpenSSH, PEM, MD5/SHA256 fingerprints
- **Private Key**: PEM, OpenSSH (sensitive outputs)
- **Secrets Manager**: secret ID, ARN, name, version
- **Usage Commands**: SSH, retrieve secret, decrypt Windows password
- **Algorithm Info**: algorithm used, key size/curve

### IAM Permissions
Required for module:
- `ec2:CreateKeyPair`, `ec2:DeleteKeyPair`, `ec2:DescribeKeyPairs`
- `secretsmanager:CreateSecret`, `secretsmanager:DeleteSecret`, etc.

Required for key retrieval:
- `secretsmanager:GetSecretValue`

### Comparison with Manual Keys

| Feature | Manual Process | This Module |
|---------|----------------|-------------|
| Key Generation | Manual (ssh-keygen) | ✅ Automatic |
| AWS Upload | Manual (console/CLI) | ✅ Automatic |
| Storage | Local .pem files | ✅ Secrets Manager |
| Encryption | File permissions | ✅ KMS |
| Access Control | File ownership | ✅ IAM policies |
| Audit | None | ✅ CloudTrail |
| Team Sharing | File sharing (insecure) | ✅ IAM permissions |
| Rotation | Manual recreation | ✅ Automatic (optional) |
| Recovery | Risky/impossible | ✅ 7-30 day window |
| Compliance | Difficult | ✅ Built-in |

### Best Practices
1. Use Secrets Manager for all production environments
2. Never enable `create_private_key_file` in production
3. Use RSA 4096 or ED25519 algorithms
4. Implement custom KMS keys for sensitive workloads
5. Tag secrets for cost allocation and access control
6. Set appropriate recovery windows
7. Restrict IAM permissions for secret access
8. Enable CloudTrail logging
9. Implement key rotation policies
10. Document key pair usage and ownership

### Known Limitations
- Secret rotation requires custom Lambda function
- ED25519 may not work with very old SSH clients
- Local files are not recommended for production
- Cannot import existing key pairs (must create new)

### Migration Notes
- This is the initial release (no migration needed)
- To migrate from manual keys: create new keys, update instances, test, delete old
- Follow organizational naming convention standards
- Ensure Secrets Manager is available in your region
- Plan for key rotation strategy

### Related Modules
- `../ec2-linux/` - Linux EC2 instances requiring key pairs
- `../ec2-windows/` - Windows EC2 instances requiring key pairs

### Secret Structure
Secrets are stored in JSON format:
```json
{
  "key_name": "tsk-prod-app-linux-01",
  "key_pair_id": "key-0123456789abcdef",
  "algorithm": "RSA",
  "private_key": "-----BEGIN RSA PRIVATE KEY-----\n...",
  "public_key": "ssh-rsa AAAAB3NzaC1...",
  "fingerprint": "ab:cd:ef:12:34:56:78:90",
  "created_at": "2025-11-06T12:00:00Z"
}
```

### Notes
- TLS provider generates keys locally, then uploads to AWS
- Private keys never leave the Terraform state during creation
- State file contains sensitive private keys - secure your state storage
- Consider using encrypted remote state (S3 with KMS)
- Secrets Manager provides better long-term key storage than state files
- Key pair deletion is immediate (non-recoverable) unless you have secret backup
