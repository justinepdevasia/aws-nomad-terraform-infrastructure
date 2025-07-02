# ==============================================================================
# GENERAL VARIABLES
# ==============================================================================

variable "region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "us-west-2"
}

variable "environment" {
  description = "Environment name (dev, qa, prod)"
  type        = string
  
  validation {
    condition     = contains(["dev", "qa", "prod"], var.environment)
    error_message = "Environment must be one of: dev, qa, prod."
  }
}

variable "aws_profile" {
  description = "AWS profile to use for deployment"
  type        = string
  default     = "default"
}

# ==============================================================================
# SECURITY VARIABLES
# ==============================================================================

variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed to access ALB and other resources"
  type        = list(string)
  default     = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
}

variable "admin_cidr_blocks" {
  description = "List of CIDR blocks for administrative access"
  type        = list(string)
  default     = []
}

variable "enable_public_access" {
  description = "Whether to allow public internet access (0.0.0.0/0) - NOT recommended for production"
  type        = bool
  default     = false
}

variable "nomad_gossip_encrypt_key" {
  description = "Base64 encoded gossip encryption key for Nomad"
  type        = string
  default     = ""
  sensitive   = true
}

variable "nomad_acl_bootstrap_token" {
  description = "Bootstrap token for Nomad ACLs"
  type        = string
  default     = ""
  sensitive   = true
}

variable "consul_gossip_encrypt_key" {
  description = "Base64 encoded gossip encryption key for Consul"
  type        = string
  default     = ""
  sensitive   = true
}

# ==============================================================================
# NETWORK VARIABLES
# ==============================================================================

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "database_subnets" {
  description = "List of database subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]
}

# ==============================================================================
# LOAD BALANCER & SSL VARIABLES
# ==============================================================================

variable "alb_certificate_arn" {
  description = "ARN of the SSL certificate for the ALB"
  type        = string
}

variable "alb_domain_certificate_arns" {
  description = "List of ARNs for domain-specific SSL certificates"
  type        = list(string)
  default     = []
}

variable "client_host_adress_list" {
  description = "List of hostnames for client ALB"
  type        = list(string)
  default     = []
}

variable "nomad_host_name" {
  description = "Hostname for Nomad UI"
  type        = string
}

variable "consul_host_name" {
  description = "Hostname for Consul UI"
  type        = string
}

# ==============================================================================
# COMPUTE VARIABLES
# ==============================================================================

variable "ami" {
  description = "AMI ID to use for EC2 instances"
  type        = string
}

variable "key_name" {
  description = "Name of the SSH key pair for EC2 instances"
  type        = string
  default     = ""
}

# ==============================================================================
# CONSUL SERVER VARIABLES
# ==============================================================================

variable "consul_server_min_size" {
  description = "Minimum number of Consul servers"
  type        = number
  default     = 1
}

variable "consul_server_max_size" {
  description = "Maximum number of Consul servers"
  type        = number
  default     = 5
}

variable "consul_server_desired_capacity" {
  description = "Desired number of Consul servers"
  type        = number
  default     = 3
}

variable "consul_server_instance_type" {
  description = "Instance type for Consul servers"
  type        = string
  default     = "t3.micro"
}

# ==============================================================================
# NOMAD SERVER VARIABLES
# ==============================================================================

variable "nomad_server_min_size" {
  description = "Minimum number of Nomad servers"
  type        = number
  default     = 1
}

variable "nomad_server_max_size" {
  description = "Maximum number of Nomad servers"
  type        = number
  default     = 5
}

variable "nomad_server_desired_capacity" {
  description = "Desired number of Nomad servers"
  type        = number
  default     = 3
}

variable "nomad_server_instance_type" {
  description = "Instance type for Nomad servers"
  type        = string
  default     = "t3.micro"
}

# ==============================================================================
# NOMAD CLIENT VARIABLES - DJANGO
# ==============================================================================

variable "nomad_client_django_min_size" {
  description = "Minimum number of Django client nodes"
  type        = number
  default     = 1
}

variable "nomad_client_django_max_size" {
  description = "Maximum number of Django client nodes"
  type        = number
  default     = 10
}

variable "nomad_client_django_desired_capacity" {
  description = "Desired number of Django client nodes"
  type        = number
  default     = 2
}

variable "nomad_client_django_instance_type" {
  description = "Instance type for Django client nodes"
  type        = string
  default     = "t3a.small"
}

# ==============================================================================
# NOMAD CLIENT VARIABLES - ELIXIR
# ==============================================================================

variable "nomad_client_elixir_min_size" {
  description = "Minimum number of Elixir client nodes"
  type        = number
  default     = 1
}

variable "nomad_client_elixir_max_size" {
  description = "Maximum number of Elixir client nodes"
  type        = number
  default     = 10
}

variable "nomad_client_elixir_desired_capacity" {
  description = "Desired number of Elixir client nodes"
  type        = number
  default     = 1
}

variable "nomad_client_elixir_instance_type" {
  description = "Instance type for Elixir client nodes"
  type        = string
  default     = "t3.micro"
}

# ==============================================================================
# NOMAD CLIENT VARIABLES - APM
# ==============================================================================

variable "nomad_client_apm_min_size" {
  description = "Minimum number of APM client nodes"
  type        = number
  default     = 1
}

variable "nomad_client_apm_max_size" {
  description = "Maximum number of APM client nodes"
  type        = number
  default     = 5
}

variable "nomad_client_apm_desired_capacity" {
  description = "Desired number of APM client nodes"
  type        = number
  default     = 1
}

variable "nomad_client_apm_instance_type" {
  description = "Instance type for APM client nodes"
  type        = string
  default     = "t3a.small"
}

# ==============================================================================
# NOMAD CLIENT VARIABLES - CELERY
# ==============================================================================

variable "nomad_client_celery_min_size" {
  description = "Minimum number of Celery client nodes"
  type        = number
  default     = 1
}

variable "nomad_client_celery_max_size" {
  description = "Maximum number of Celery client nodes"
  type        = number
  default     = 10
}

variable "nomad_client_celery_desired_capacity" {
  description = "Desired number of Celery client nodes"
  type        = number
  default     = 1
}

variable "nomad_client_celery_instance_type" {
  description = "Instance type for Celery client nodes"
  type        = string
  default     = "t3a.small"
}

# ==============================================================================
# NOMAD CLIENT VARIABLES - RABBITMQ
# ==============================================================================

variable "nomad_client_rabbit_min_size" {
  description = "Minimum number of RabbitMQ client nodes"
  type        = number
  default     = 1
}

variable "nomad_client_rabbit_max_size" {
  description = "Maximum number of RabbitMQ client nodes"
  type        = number
  default     = 5
}

variable "nomad_client_rabbit_desired_capacity" {
  description = "Desired number of RabbitMQ client nodes"
  type        = number
  default     = 1
}

variable "nomad_client_rabbit_instance_type" {
  description = "Instance type for RabbitMQ client nodes"
  type        = string
  default     = "t3.micro"
}

# ==============================================================================
# NOMAD CLIENT VARIABLES - TRAEFIK
# ==============================================================================

variable "nomad_client_traefik_min_size" {
  description = "Minimum number of Traefik client nodes"
  type        = number
  default     = 1
}

variable "nomad_client_traefik_max_size" {
  description = "Maximum number of Traefik client nodes"
  type        = number
  default     = 5
}

variable "nomad_client_traefik_desired_capacity" {
  description = "Desired number of Traefik client nodes"
  type        = number
  default     = 1
}

variable "nomad_client_traefik_instance_type" {
  description = "Instance type for Traefik client nodes"
  type        = string
  default     = "t3.micro"
}

# ==============================================================================
# NOMAD CLIENT VARIABLES - DATASTORE
# ==============================================================================

variable "nomad_client_datastore_min_size" {
  description = "Minimum number of Datastore client nodes"
  type        = number
  default     = 1
}

variable "nomad_client_datastore_max_size" {
  description = "Maximum number of Datastore client nodes"
  type        = number
  default     = 5
}

variable "nomad_client_datastore_desired_capacity" {
  description = "Desired number of Datastore client nodes"
  type        = number
  default     = 2
}

variable "nomad_client_datastore_instance_type" {
  description = "Instance type for Datastore client nodes"
  type        = string
  default     = "t3.micro"
}

# ==============================================================================
# ECR VARIABLES
# ==============================================================================

variable "ecr_name" {
  description = "List of ECR repository names to create"
  type        = list(string)
  default     = []
}

variable "ecr_address" {
  description = "ECR registry address"
  type        = string
}

variable "image_mutability" {
  description = "Image tag mutability setting for ECR repositories"
  type        = string
  default     = "MUTABLE"
  
  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_mutability)
    error_message = "Image mutability must be either MUTABLE or IMMUTABLE."
  }
}

# ==============================================================================
# S3 STORAGE VARIABLES
# ==============================================================================

variable "web_bucket" {
  description = "Name of the S3 bucket for web assets"
  type        = string
}

variable "media_bucket" {
  description = "Name of the S3 bucket for media files"
  type        = string
}

variable "django_static_public_prefix" {
  description = "S3 prefix for Django static files"
  type        = string
  default     = "static/django/"
}

variable "django_media_public_prefix" {
  description = "S3 prefix for Django media files"
  type        = string
  default     = "media/django/"
}

variable "elixir_static_public_prefix" {
  description = "S3 prefix for Elixir static files"
  type        = string
  default     = "static/elixir/"
}

variable "elixir_media_public_prefix" {
  description = "S3 prefix for Elixir media files"
  type        = string
  default     = "media/elixir/"
}

# ==============================================================================
# TAGS
# ==============================================================================

variable "tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default = {
    Terraform   = "true"
    Project     = "nomad-infrastructure"
  }
}

# ==============================================================================
# ROUTE53 VARIABLES
# ==============================================================================

variable "route_53_resolver_address" {
  description = "Route53 resolver address for DNS resolution"
  type        = string
  default     = "10.0.0.2"
}
