# ==============================================================================
# BASIC CONFIGURATION
# ==============================================================================

region                  = "us-west-2"
environment             = "dev"
aws_profile             = "default"

# ==============================================================================
# SECURITY CONFIGURATION
# ==============================================================================

# IMPORTANT: Configure these CIDR blocks for your environment
# Default allows RFC1918 private networks only (more secure than 0.0.0.0/0)
allowed_cidr_blocks = [
  "10.0.0.0/8",     # Private networks
  "172.16.0.0/12",  # Private networks  
  "192.168.0.0/16"  # Private networks
]

# Admin access - restrict to your office/VPN IP ranges
admin_cidr_blocks = [
  # "203.0.113.0/24",  # Example: Your office IP range
  # "198.51.100.0/24", # Example: Your VPN IP range
]

# WARNING: Only enable for development - NOT for production
enable_public_access = true  # Set to false for production

# Leave empty to auto-generate secure keys (recommended)
nomad_gossip_encrypt_key  = ""
nomad_acl_bootstrap_token = ""
consul_gossip_encrypt_key = ""

# ==============================================================================
# NETWORK CONFIGURATION
# ==============================================================================

vpc_cidr           = "10.0.0.0/16"
availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
public_subnets     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
private_subnets    = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
database_subnets   = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]

# ==============================================================================
# SSL CERTIFICATES
# ==============================================================================

alb_certificate_arn = "arn:aws:acm:us-west-2:786731984788:certificate/12345678-1234-1234-1234-123456789012"

alb_domain_certificate_arns = [
  "arn:aws:acm:us-west-2:786731984788:certificate/f74eb27e-0f57-4e95-b61d-2db7de507ef8",
  "arn:aws:acm:us-west-2:786731984788:certificate/eaa4645e-c6a0-4e92-aa0e-f83ac6a07b0f"
]

# ==============================================================================
# HOSTNAMES
# ==============================================================================

client_host_adress_list = ["stage.api.example.com", "stage.example.com"]
nomad_host_name         = "nomad.develop.example.com"
consul_host_name        = "consul.develop.example.com"

# ==============================================================================
# COMPUTE RESOURCES
# ==============================================================================

# Update this with your custom AMI ID after building with Packer
ami = "ami-0f2ab35e75ec8c4fe"

# SSH key for EC2 access (optional)
# key_name = "my-ssh-key"

# ==============================================================================
# ECR CONFIGURATION
# ==============================================================================

ecr_address      = "786731984788.dkr.ecr.us-west-2.amazonaws.com"
image_mutability = "MUTABLE"

ecr_name = [
  "company/backend",
  "company/authentication",
  "company/engine",
]

# ==============================================================================
# CLUSTER SIZING - DEVELOPMENT
# ==============================================================================

# Consul Servers
consul_server_min_size         = 1
consul_server_max_size         = 1
consul_server_desired_capacity = 1
consul_server_instance_type    = "t3.micro"

# Nomad Servers
nomad_server_min_size         = 1
nomad_server_max_size         = 1
nomad_server_desired_capacity = 1
nomad_server_instance_type    = "t3.micro"

# Nomad Clients - APM
nomad_client_apm_min_size         = 1
nomad_client_apm_max_size         = 1
nomad_client_apm_desired_capacity = 1
nomad_client_apm_instance_type    = "t3a.small"

# Nomad Clients - Django
nomad_client_django_min_size         = 2
nomad_client_django_max_size         = 2
nomad_client_django_desired_capacity = 2
nomad_client_django_instance_type    = "t3a.small"

# Nomad Clients - Elixir
nomad_client_elixir_min_size         = 1
nomad_client_elixir_max_size         = 1
nomad_client_elixir_desired_capacity = 1
nomad_client_elixir_instance_type    = "t3.micro"

# Nomad Clients - Traefik
nomad_client_traefik_min_size         = 1
nomad_client_traefik_max_size         = 1
nomad_client_traefik_desired_capacity = 1
nomad_client_traefik_instance_type    = "t3.micro"

# Nomad Clients - RabbitMQ
nomad_client_rabbit_min_size         = 1
nomad_client_rabbit_max_size         = 1
nomad_client_rabbit_desired_capacity = 1
nomad_client_rabbit_instance_type    = "t3.micro"

# Nomad Clients - Celery
nomad_client_celery_min_size         = 1
nomad_client_celery_max_size         = 1
nomad_client_celery_desired_capacity = 1
nomad_client_celery_instance_type    = "t3a.small"

# Nomad Clients - Datastore
nomad_client_datastore_min_size         = 2
nomad_client_datastore_max_size         = 2
nomad_client_datastore_desired_capacity = 2
nomad_client_datastore_instance_type    = "t3.micro"

# ==============================================================================
# STORAGE CONFIGURATION
# ==============================================================================

media_bucket = "app-media-bucket-dev"
web_bucket   = "app-web-bucket-dev"

django_static_public_prefix = "static/backend/public"
elixir_static_public_prefix = "static/engine/public"
django_media_public_prefix  = "media/backend/public"
elixir_media_public_prefix  = "media/engine/public"

# ==============================================================================
# DNS CONFIGURATION
# ==============================================================================

route_53_resolver_address = "10.0.0.2"

# ==============================================================================
# TAGS
# ==============================================================================

tags = {
  Terraform   = "true"
  Environment = "development"
  Project     = "nomad-infrastructure"
  Owner       = "devops-team"
  CostCenter  = "engineering"
}
