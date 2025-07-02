# AWS Nomad Terraform Infrastructure

![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Nomad](https://img.shields.io/badge/nomad-%2300D4FF.svg?style=for-the-badge&logo=nomad&logoColor=white)
![Consul](https://img.shields.io/badge/consul-%23F24C53.svg?style=for-the-badge&logo=consul&logoColor=white)

A production-ready, enterprise-scale infrastructure-as-code solution for deploying HashiCorp Nomad clusters on AWS. This project provides a complete orchestration platform supporting microservices architectures with Django, Elixir, and other containerized applications.

## 🏗️ Architecture Overview

This infrastructure creates a robust, multi-tier HashiCorp stack with the following components:

### Core Services
- **Nomad Cluster**: Container orchestration and scheduling
- **Consul Cluster**: Service discovery, configuration, and networking
- **Traefik**: Dynamic reverse proxy and load balancer
- **Application Load Balancers**: High-availability ingress

### Specialized Node Pools
- **Django Clients**: Python/Django application workloads
- **Elixir Clients**: Elixir/Phoenix application workloads  
- **Celery Clients**: Distributed task processing
- **RabbitMQ Clients**: Message queue services
- **APM Clients**: Application performance monitoring
- **Datastore Clients**: Database and storage workloads

### Supporting Infrastructure
- **VPC**: Multi-AZ networking (us-west-2a/b/c)
- **ECR**: Container image registry
- **RDS PostgreSQL**: Managed database
- **S3 + CloudFront**: Static assets and CDN
- **Auto Scaling Groups**: Dynamic capacity management

## 🚀 Quick Start

### Prerequisites
- [Terraform](https://terraform.io/downloads.html) >= 1.0
- [Packer](https://packer.io/downloads.html) >= 1.7
- AWS CLI configured with appropriate permissions
- SSH key pair for EC2 access

### 1. Build Custom AMI
```bash
cd packer/
packer build -var 'region=us-west-2' ami.pkr.hcl
```

### 2. Setup Remote State (First Time)
```bash
cd tf-remote-state/dev/
terraform init
terraform apply
```

### 3. Deploy Infrastructure
```bash
cd tf-infra/
terraform init -backend-config="backend_develop.conf"
terraform plan -var-file="develop.tfvars"
terraform apply -var-file="develop.tfvars"
```

## 📁 Project Structure

```
├── tf-infra/                  # Main infrastructure code
│   ├── modules/              # Reusable Terraform modules
│   │   ├── vpc/             # Network infrastructure
│   │   ├── consul-servers/  # Consul cluster
│   │   ├── nomad-servers/   # Nomad cluster
│   │   ├── nomad-clients-*/ # Specialized client pools
│   │   ├── firewall/        # Security groups
│   │   └── ...
│   ├── main.tf              # Main configuration
│   ├── variables.tf         # Input variables
│   ├── outputs.tf           # Infrastructure outputs
│   ├── providers.tf         # Provider configuration
│   ├── backend.tf           # Remote state configuration
│   ├── develop.tfvars       # Development environment
│   └── main.tfvars          # Production environment
├── packer/                   # AMI building
│   ├── ami.pkr.hcl          # Packer template
│   ├── scripts/             # Provisioning scripts
│   └── config/              # Configuration files
├── tf-remote-state/          # State management
│   ├── dev/
│   ├── qa/
│   └── prod/
└── bitbucket-pipelines.yml   # CI/CD pipeline
```

## 🌍 Multi-Environment Support

The infrastructure supports multiple isolated environments:

| Environment | Purpose | Instance Sizes | High Availability |
|-------------|---------|----------------|-------------------|
| Development | Testing and development | t3.micro/small | Single AZ |
| QA | Quality assurance and staging | t3.small/medium | Multi AZ |
| Production | Live workloads | t3.medium/large+ | Multi AZ |

## 🔧 Configuration

### Environment Variables
Key variables to customize in `.tfvars` files:

```hcl
# Basic Configuration
region                    = "us-west-2"
environment              = "dev"
ami                      = "ami-xxxxxxxxx"

# Networking
vpc_cidr                 = "10.0.0.0/16" 
availability_zones       = ["us-west-2a", "us-west-2b", "us-west-2c"]

# Cluster Sizing
nomad_server_desired_capacity = 3
consul_server_desired_capacity = 3
nomad_client_django_desired_capacity = 2

# Security
allowed_cidr_blocks      = ["10.0.0.0/8", "172.16.0.0/12"]
alb_certificate_arn      = "arn:aws:acm:..."

# Application
ecr_address              = "123456789.dkr.ecr.us-west-2.amazonaws.com"
```

### Security Configuration
- All sensitive values use Terraform variables or AWS Secrets Manager
- Security groups follow principle of least privilege  
- TLS encryption for all inter-service communication
- ACL tokens and encryption keys generated securely

## 🏃‍♂️ Running Applications

### Deploy a Service
```hcl
job "web-app" {
  datacenters = ["dc1"]
  
  group "web" {
    count = 3
    
    constraint {
      attribute = "${node.class}"
      value     = "django"
    }
    
    task "app" {
      driver = "docker"
      
      config {
        image = "your-ecr-repo/app:latest"
        ports = ["http"]
      }
      
      service {
        name = "web-app"
        port = "http"
        
        check {
          type     = "http"
          path     = "/health"
          interval = "10s"
          timeout  = "3s"
        }
      }
    }
  }
}
```

### Access Services
- **Nomad UI**: `https://nomad.your-domain.com`
- **Consul UI**: `https://consul.your-domain.com`  
- **Applications**: `https://app.your-domain.com`

## 🔒 Security Features

- **Network Isolation**: Private subnets for all workloads
- **TLS Encryption**: End-to-end encrypted communication
- **IAM Roles**: Least-privilege access controls
- **Security Groups**: Restrictive firewall rules
- **Secrets Management**: AWS Secrets Manager integration
- **ACL Tokens**: Consul and Nomad access controls

## 📊 Monitoring & Observability

The infrastructure includes built-in observability:

- **APM Integration**: Application performance monitoring
- **Health Checks**: Service-level health monitoring  
- **Log Aggregation**: Centralized logging via Nomad
- **Metrics Collection**: Prometheus-compatible metrics
- **Distributed Tracing**: Request tracing capabilities

## 🚀 CI/CD Integration

Automated deployment pipeline using Bitbucket Pipelines:

```yaml
# Automatic on develop branch
- Terraform plan validation
- Security scanning
- Manual deployment approval

# Production deployment
- Multi-stage approval process
- Blue-green deployment support
- Automatic rollback capabilities
```

## 🔧 Troubleshooting

### Common Issues

1. **AMI Not Found**
   ```bash
   # Rebuild the AMI
   cd packer/
   packer build ami.pkr.hcl
   ```

2. **Service Discovery Issues**
   ```bash
   # Check Consul cluster health
   consul members
   consul operator raft list-peers
   ```

3. **Job Scheduling Problems**
   ```bash
   # Check Nomad cluster status
   nomad server members
   nomad node status
   ```

### Useful Commands

```bash
# Check infrastructure status
terraform show
terraform state list

# Nomad operations
nomad job run job.nomad
nomad job status web-app
nomad alloc logs <alloc-id>

# Consul operations
consul catalog services
consul kv get -recurse config/
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Workflow
```bash
# Format code
terraform fmt -recursive

# Validate configuration  
terraform validate

# Plan changes
terraform plan -var-file="develop.tfvars"

# Run security scan
tfsec .
```

## 📋 Requirements

### AWS Permissions
The deploying user/role needs permissions for:
- EC2 (instances, VPC, security groups, load balancers)
- IAM (roles, policies, instance profiles)
- S3 (buckets, objects)
- RDS (instances, subnet groups)
- ECR (repositories)
- ACM (certificates)
- CloudFront (distributions)
- Route53 (DNS records)

### Terraform Modules
All modules are self-contained with:
- Input validation
- Output values  
- Documentation
- Example usage

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- **Documentation**: Check the `/docs` directory
- **Issues**: Use GitHub Issues for bug reports
- **Discussions**: Use GitHub Discussions for questions
- **Security**: Email security@your-domain.com for vulnerabilities

---

**Built with ❤️ using HashiCorp tools and AWS**
