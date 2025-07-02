# Security Guide

## Overview

This document outlines the security improvements made to the AWS Nomad Terraform Infrastructure and provides best practices for secure deployment.

## 🔒 Security Improvements Implemented

### 1. Network Access Controls

**Before:**
- Hardcoded `whitelist_ip = "0.0.0.0/0"` allowing unrestricted internet access

**After:**
- Configurable CIDR blocks via variables
- Separate access controls for different services:
  - `allowed_cidr_blocks`: For application load balancers
  - `admin_cidr_blocks`: For administrative access (Nomad/Consul UIs)
- `enable_public_access` flag for explicit control

### 2. Encryption Key Management

**Before:**
- Hardcoded encryption keys and tokens in main.tf
- Sensitive values committed to version control

**After:**
- Auto-generation of secure encryption keys
- Support for external key management
- Marked sensitive values appropriately
- Keys stored securely and not committed to git

### 3. Environment-Based Security

**Development:**
- More permissive settings for ease of development
- Public access can be enabled with explicit flag

**Production:**
- Restrictive CIDR blocks only
- Public access disabled by default
- Immutable ECR tags
- Higher instance types for better isolation

## 🛡️ Security Configuration

### Network Security

```hcl
# Secure production configuration
allowed_cidr_blocks = [
  "10.0.0.0/8",       # Your VPC
  "172.16.0.0/12",    # Corporate network
  "203.0.113.0/24",   # Office IP range
]

admin_cidr_blocks = [
  "203.0.113.100/32", # DevOps workstation
  "198.51.100.0/28",  # Management subnet
]

enable_public_access = false  # Never true in production
```

### Encryption Configuration

```hcl
# Auto-generated secure keys (recommended)
nomad_gossip_encrypt_key  = ""
nomad_acl_bootstrap_token = ""
consul_gossip_encrypt_key = ""

# Or provide via environment variables:
# export TF_VAR_nomad_gossip_encrypt_key="base64-encoded-key"
```

## 🚨 Security Best Practices

### 1. Access Management

- **Principle of Least Privilege**: Only grant necessary access
- **Network Segmentation**: Use private subnets for workloads
- **VPN Access**: Require VPN for administrative access
- **Multi-Factor Authentication**: Enable MFA for AWS accounts

### 2. Secrets Management

- **Never commit secrets**: Use environment variables or AWS Secrets Manager
- **Rotate keys regularly**: Implement key rotation policies
- **Use IAM roles**: Prefer IAM roles over access keys
- **Enable audit logging**: Monitor access to sensitive resources

### 3. Infrastructure Security

- **Regular updates**: Keep AMIs and software updated
- **Security scanning**: Use tools like `tfsec` or `checkov`
- **Monitoring**: Implement comprehensive logging and monitoring
- **Backup strategy**: Regular backups of critical data

### 4. Application Security

- **TLS everywhere**: Encrypt all communication
- **Service mesh**: Use Consul Connect for service-to-service encryption
- **ACL policies**: Implement fine-grained access controls
- **Health checks**: Monitor service health continuously

## 🔍 Security Validation

### Pre-deployment Checks

```bash
# Terraform security scanning
tfsec .

# Validate configuration
terraform validate

# Review planned changes
terraform plan -var-file="production.tfvars"
```

### Post-deployment Verification

```bash
# Check Nomad cluster security
nomad operator raft list-peers
nomad acl token list

# Check Consul cluster security
consul members
consul acl policy list

# Verify network connectivity
nmap -p 4646,8500 nomad.yourdomain.com
```

## 🚀 Deployment Security

### Secure Deployment Process

1. **Environment Isolation**
   - Separate AWS accounts for different environments
   - Isolated VPCs and networks
   - Environment-specific IAM roles

2. **CI/CD Security**
   - Secure pipeline configuration
   - Secret management in CI/CD
   - Approval processes for production

3. **Infrastructure as Code**
   - Version control all changes
   - Code review requirements
   - Automated testing and validation

### Emergency Procedures

1. **Security Incident Response**
   - Immediate access revocation procedures
   - Incident escalation paths
   - Recovery and forensics processes

2. **Key Compromise**
   - Key rotation procedures
   - Service restart protocols
   - Impact assessment guidelines

## 📋 Security Checklist

### Development Environment
- [ ] Configure appropriate CIDR blocks
- [ ] Enable logging and monitoring
- [ ] Use secure AMIs
- [ ] Implement basic access controls

### Production Environment
- [ ] Disable public access (`enable_public_access = false`)
- [ ] Configure restrictive CIDR blocks
- [ ] Use immutable ECR tags
- [ ] Enable comprehensive monitoring
- [ ] Implement backup strategies
- [ ] Configure alerting
- [ ] Document incident response procedures
- [ ] Regular security assessments
- [ ] Key rotation schedule
- [ ] Access review processes

## 🔧 Troubleshooting Security Issues

### Common Security Problems

1. **Cannot access Nomad/Consul UI**
   - Check `admin_cidr_blocks` configuration
   - Verify VPN connectivity
   - Confirm security group rules

2. **Service communication failures**
   - Verify Consul Connect configuration
   - Check service mesh policies
   - Validate TLS certificates

3. **Authentication errors**
   - Verify ACL token configuration
   - Check token permissions
   - Confirm gossip key synchronization

### Security Monitoring

```bash
# Monitor failed authentication attempts
nomad monitor -log-level=WARN

# Check Consul security events
consul monitor -log-level=WARN

# Review AWS CloudTrail logs
aws logs filter-log-events --log-group-name="/aws/cloudtrail"
```

## 📞 Security Contacts

- **Security Team**: security@yourdomain.com
- **DevOps Team**: devops@yourdomain.com
- **Incident Response**: incident@yourdomain.com

## 📚 Additional Resources

- [HashiCorp Nomad Security Guide](https://learn.hashicorp.com/nomad/security)
- [HashiCorp Consul Security Guide](https://learn.hashicorp.com/consul/security)
- [AWS Security Best Practices](https://aws.amazon.com/architecture/security-identity-compliance/)
- [Terraform Security Best Practices](https://blog.terraform.io/terraform-security-best-practices)

---

**Remember: Security is an ongoing process, not a one-time configuration. Regularly review and update your security posture.**
