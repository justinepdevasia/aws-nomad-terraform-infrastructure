# ==============================================================================
# VPC OUTPUTS
# ==============================================================================

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = var.vpc_cidr
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnet_ids
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnet_ids
}

output "database_subnet_ids" {
  description = "List of IDs of database subnets"
  value       = module.vpc.database_subnet_ids
}

output "database_subnet_group" {
  description = "Database subnet group name"
  value       = module.vpc.database_subnet_group
}

# ==============================================================================
# LOAD BALANCER OUTPUTS
# ==============================================================================

output "server_alb_dns_name" {
  description = "DNS name of the server ALB"
  value       = module.server_alb.alb_dns_name
}

output "server_alb_zone_id" {
  description = "Zone ID of the server ALB"
  value       = module.server_alb.alb_zone_id
}

output "client_alb_dns_name" {
  description = "DNS name of the client ALB"
  value       = module.client_alb.alb_dns_name
}

output "client_alb_zone_id" {
  description = "Zone ID of the client ALB"
  value       = module.client_alb.alb_zone_id
}

# ==============================================================================
# NOMAD CLUSTER OUTPUTS
# ==============================================================================

output "nomad_ui_url" {
  description = "URL to access Nomad UI"
  value       = "https://${var.nomad_host_name}"
}

output "nomad_api_endpoint" {
  description = "Nomad API endpoint for programmatic access"
  value       = "https://${var.nomad_host_name}:4646"
}

output "nomad_server_target_group_arn" {
  description = "ARN of the Nomad server target group"
  value       = try(module.server_alb.alb_server_target_groups.nomad_arn, null)
}

output "nomad_acl_bootstrap_token" {
  description = "Nomad ACL bootstrap token for initial setup"
  value       = local.nomad_acl_token
  sensitive   = true
}

output "nomad_gossip_encrypt_key" {
  description = "Nomad gossip encryption key"
  value       = local.nomad_gossip_key
  sensitive   = true
}

# ==============================================================================
# CONSUL CLUSTER OUTPUTS
# ==============================================================================

output "consul_ui_url" {
  description = "URL to access Consul UI"
  value       = "https://${var.consul_host_name}"
}

output "consul_api_endpoint" {
  description = "Consul API endpoint for programmatic access"
  value       = "https://${var.consul_host_name}:8500"
}

output "consul_server_target_group_arn" {
  description = "ARN of the Consul server target group"
  value       = try(module.server_alb.alb_server_target_groups.consul_arn, null)
}

output "consul_gossip_encrypt_key" {
  description = "Consul gossip encryption key"
  value       = local.consul_gossip_key
  sensitive   = true
}

# ==============================================================================
# SECURITY GROUP OUTPUTS
# ==============================================================================

output "server_alb_security_group_id" {
  description = "Security group ID for server ALB"
  value       = module.firewall.server_alb_security_group_id
}

output "client_alb_security_group_id" {
  description = "Security group ID for client ALB"
  value       = module.firewall.client_alb_security_group_id
}

output "ec2_security_group_id" {
  description = "Security group ID for EC2 instances"
  value       = module.firewall.ec2_security_group_id
}

output "postgres_security_group_id" {
  description = "Security group ID for PostgreSQL database"
  value       = module.firewall.postgres_security_group_id
}

# ==============================================================================
# ECR OUTPUTS
# ==============================================================================

output "ecr_repository_urls" {
  description = "URLs of the ECR repositories"
  value       = module.ecr.repository_urls
}

output "ecr_registry_id" {
  description = "Registry ID of the ECR repositories"
  value       = module.ecr.registry_id
}

# ==============================================================================
# STORAGE OUTPUTS
# ==============================================================================

output "web_bucket_name" {
  description = "Name of the S3 bucket for web assets"
  value       = var.itsy_web_bucket
}

output "media_bucket_name" {
  description = "Name of the S3 bucket for media files"
  value       = var.itsy_media_bucket
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = try(module.itsy_storage.cloudfront_distribution_id, null)
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = try(module.itsy_storage.cloudfront_domain_name, null)
}

# ==============================================================================
# DATABASE OUTPUTS
# ==============================================================================

output "postgres_endpoint" {
  description = "PostgreSQL database endpoint"
  value       = try(module.itsy_postgres.endpoint, null)
  sensitive   = true
}

output "postgres_port" {
  description = "PostgreSQL database port"
  value       = try(module.itsy_postgres.port, null)
}

# ==============================================================================
# AUTO SCALING GROUP OUTPUTS
# ==============================================================================

output "consul_asg_name" {
  description = "Name of the Consul server Auto Scaling Group"
  value       = try(module.consul_servers.asg_name, null)
}

output "nomad_server_asg_name" {
  description = "Name of the Nomad server Auto Scaling Group"
  value       = try(module.nomad_servers.asg_name, null)
}

output "nomad_client_asg_names" {
  description = "Names of Nomad client Auto Scaling Groups"
  value = {
    django    = try(module.nomad_clients_django.asg_name, null)
    elixir    = try(module.nomad_clients_elixir.asg_name, null)
    rabbitmq  = try(module.nomad_clients_rabbitmq.asg_name, null)
    apm       = try(module.nomad_clients_apm.asg_name, null)
    traefik   = try(module.nomad_clients_traefik.asg_name, null)
    celery    = try(module.nomad_clients_celery.asg_name, null)
    datastore = try(module.nomad_clients_datastore.asg_name, null)
  }
}

# ==============================================================================
# ENVIRONMENT AND METADATA OUTPUTS
# ==============================================================================

output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "region" {
  description = "AWS region"
  value       = var.region
}

output "availability_zones" {
  description = "Availability zones used"
  value       = var.availability_zones
}

# ==============================================================================
# ACCESS INFORMATION
# ==============================================================================

output "cluster_access_info" {
  description = "Information for accessing the cluster"
  value = {
    nomad_ui          = "https://${var.nomad_host_name}"
    consul_ui         = "https://${var.consul_host_name}"
    applications      = var.client_host_adress_list
    server_alb_dns    = module.server_alb.alb_dns_name
    client_alb_dns    = module.client_alb.alb_dns_name
  }
}

# ==============================================================================
# USEFUL COMMANDS OUTPUT
# ==============================================================================

output "useful_commands" {
  description = "Useful commands for managing the infrastructure"
  value = {
    nomad_status = "nomad server members"
    consul_status = "consul members"
    nomad_jobs = "nomad job status"
    consul_services = "consul catalog services"
    ssh_command = "ssh -i ~/.ssh/your-key.pem ec2-user@<instance-ip>"
  }
}

# ==============================================================================
# SECURITY ACCESS INFORMATION
# ==============================================================================

output "security_access_info" {
  description = "Information about security access configuration"
  value = {
    alb_access_cidrs   = local.alb_access_cidrs
    admin_access_cidrs = local.admin_access_cidrs
    public_access_enabled = var.enable_public_access
  }
  sensitive = false
}

# ==============================================================================
# DEPLOYMENT VERIFICATION
# ==============================================================================

output "deployment_verification" {
  description = "Commands to verify deployment"
  value = {
    check_nomad_health   = "curl -k https://${var.nomad_host_name}/v1/status/leader"
    check_consul_health  = "curl -k https://${var.consul_host_name}/v1/status/leader"
    list_nomad_nodes     = "curl -k https://${var.nomad_host_name}/v1/nodes"
    list_consul_nodes    = "curl -k https://${var.consul_host_name}/v1/agent/members"
  }
}
