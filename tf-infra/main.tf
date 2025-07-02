# ==============================================================================
# DATA SOURCES
# ==============================================================================

# Generate random values for encryption if not provided
resource "random_id" "nomad_gossip_key" {
  count       = var.nomad_gossip_encrypt_key == "" ? 1 : 0
  byte_length = 32
}

resource "random_uuid" "nomad_acl_token" {
  count = var.nomad_acl_bootstrap_token == "" ? 1 : 0
}

resource "random_id" "consul_gossip_key" {
  count       = var.consul_gossip_encrypt_key == "" ? 1 : 0
  byte_length = 32
}

# Calculate allowed CIDR blocks for security groups
locals {
  # Use admin CIDR blocks for sensitive services, or fall back to allowed blocks
  admin_access_cidrs = length(var.admin_cidr_blocks) > 0 ? var.admin_cidr_blocks : var.allowed_cidr_blocks
  
  # For ALB, use allowed CIDR blocks or enable public access if explicitly requested
  alb_access_cidrs = var.enable_public_access ? ["0.0.0.0/0"] : var.allowed_cidr_blocks
  
  # Generate or use provided encryption keys
  nomad_gossip_key = var.nomad_gossip_encrypt_key != "" ? var.nomad_gossip_encrypt_key : base64encode(random_id.nomad_gossip_key[0].hex)
  nomad_acl_token  = var.nomad_acl_bootstrap_token != "" ? var.nomad_acl_bootstrap_token : random_uuid.nomad_acl_token[0].result
  consul_gossip_key = var.consul_gossip_encrypt_key != "" ? var.consul_gossip_encrypt_key : base64encode(random_id.consul_gossip_key[0].hex)
  
  # Common tags
  common_tags = merge(var.tags, {
    Environment = var.environment
    Region      = var.region
  })
}

# ==============================================================================
# ECR REPOSITORY
# ==============================================================================

module "ecr" {
  source   = "./modules/ecr"
  ecr_name = var.ecr_name
  tags     = local.common_tags
}

# ==============================================================================
# VPC AND NETWORKING
# ==============================================================================

module "vpc" {
  source     = "./modules/vpc"
  depends_on = [module.ecr]
  
  environment        = var.environment
  vpc_cidr          = var.vpc_cidr
  availability_zones = var.availability_zones
  public_subnets    = var.public_subnets
  private_subnets   = var.private_subnets
  database_subnets  = var.database_subnets
  
  tags = local.common_tags
}

# ==============================================================================
# SECURITY GROUPS
# ==============================================================================

module "firewall" {
  source = "./modules/firewall"
  
  # Use calculated CIDR blocks instead of hardcoded 0.0.0.0/0
  allowed_cidr_blocks = local.alb_access_cidrs
  admin_cidr_blocks   = local.admin_access_cidrs
  
  vpc_id   = module.vpc.vpc_id
  vpc_cidr = var.vpc_cidr
  
  tags = local.common_tags
}

# ==============================================================================
# APPLICATION LOAD BALANCERS
# ==============================================================================

module "server_alb" {
  source = "./modules/server_alb"

  vpc_id                       = module.vpc.vpc_id
  public_subnet_ids            = module.vpc.public_subnet_ids
  allowed_cidr_blocks          = local.admin_access_cidrs  # More restrictive for server access
  alb_certificate_arn          = var.alb_certificate_arn
  nomad_address                = var.nomad_host_name
  consul_address               = var.consul_host_name
  server_alb_security_group_id = module.firewall.server_alb_security_group_id
  
  tags = local.common_tags
}

module "client_alb" {
  source = "./modules/client_alb"

  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids

  client_alb_security_group_id = module.firewall.client_alb_security_group_id
  alb_certificate_arn          = var.alb_certificate_arn
  host_address_list            = var.client_host_adress_list
  alb_domain_certificate_arns  = var.alb_domain_certificate_arns

  tags = local.common_tags
}

# ==============================================================================
# CONSUL CLUSTER
# ==============================================================================

module "consul_servers" {
  depends_on = [module.vpc]
  source     = "./modules/consul-servers"

  aws_region         = var.region
  ami                = var.ami
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids

  alb_server_target_groups = module.server_alb.alb_server_target_groups
  ec2_security_group_id    = module.firewall.ec2_security_group_id

  consul_server_min_size         = var.consul_server_min_size
  consul_server_max_size         = var.consul_server_max_size
  consul_server_desired_capacity = var.consul_server_desired_capacity

  cluster_tags = merge(local.common_tags, { 
    "consul-cluster" = "consul-cluster"
    "Service"        = "consul"
  })

  consul_server_instance_type = var.consul_server_instance_type
  consul_bootstrap_expect     = var.consul_server_desired_capacity
  consul_join_tag_value       = "consul"
  consul_join_tag_key         = "consul_ec2_join"
  consul_gossip_encrypt_key   = local.consul_gossip_key

  tags = local.common_tags
}

# ==============================================================================
# NOMAD CLUSTER
# ==============================================================================

module "nomad_servers" {
  depends_on = [module.vpc]
  source     = "./modules/nomad-servers"

  aws_region         = var.region
  ami                = var.ami
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids

  alb_server_target_groups = module.server_alb.alb_server_target_groups
  ec2_security_group_id    = module.firewall.ec2_security_group_id

  nomad_server_min_size         = var.nomad_server_min_size
  nomad_server_max_size         = var.nomad_server_max_size
  nomad_server_desired_capacity = var.nomad_server_desired_capacity

  nomad_dc               = "dc1"
  cluster_tags           = merge(local.common_tags, { 
    "nomad-cluster" = "nomad-cluster"
    "Service"       = "nomad"
  })
  nomad_join_tag_value   = "nomad"
  nomad_bootstrap_expect = 1
  
  # Use generated or provided encryption keys
  nomad_gossip_encrypt_key  = local.nomad_gossip_key
  nomad_acl_bootstrap_token = local.nomad_acl_token
  
  nomad_server_instance_type = var.nomad_server_instance_type
  nomad_join_tag_key         = "nomad_ec2_join"

  consul_join_tag_value = "consul"
  consul_join_tag_key   = "consul_ec2_join"

  tags = local.common_tags
}

# ==============================================================================
# NOMAD CLIENT NODES
# ==============================================================================

module "nomad_clients_django" {
  source = "./modules/nomad-clients-django"

  aws_region         = var.region
  ami                = var.ami
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  nomad_client_django_min_size         = var.nomad_client_django_min_size
  nomad_client_django_max_size         = var.nomad_client_django_max_size
  nomad_client_django_desired_capacity = var.nomad_client_django_desired_capacity

  nomad_dc             = "dc1"
  nomad_join_tag_key   = "nomad_ec2_join"
  nomad_join_tag_value = "nomad"

  nomad_client_django_instance_type = var.nomad_client_django_instance_type
  consul_join_tag_key               = "consul_ec2_join"
  consul_join_tag_value             = "consul"

  alb_client_target_groups = module.client_alb.alb_client_target_groups
  ec2_security_group_id    = module.firewall.ec2_security_group_id

  route_53_resolver_address = var.route_53_resolver_address
  node_class                = "django"
  ecr_address               = var.ecr_address

  tags = merge(local.common_tags, { "NodeClass" = "django" })
}

module "nomad_clients_elixir" {
  source = "./modules/nomad-clients-elixir"

  aws_region         = var.region
  ami                = var.ami
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  nomad_client_elixir_min_size         = var.nomad_client_elixir_min_size
  nomad_client_elixir_max_size         = var.nomad_client_elixir_max_size
  nomad_client_elixir_desired_capacity = var.nomad_client_elixir_desired_capacity

  nomad_dc             = "dc1"
  nomad_join_tag_key   = "nomad_ec2_join"
  nomad_join_tag_value = "nomad"

  nomad_client_elixir_instance_type = var.nomad_client_elixir_instance_type
  consul_join_tag_key               = "consul_ec2_join"
  consul_join_tag_value             = "consul"

  alb_client_target_groups = module.client_alb.alb_client_target_groups
  ec2_security_group_id    = module.firewall.ec2_security_group_id

  route_53_resolver_address = var.route_53_resolver_address
  node_class                = "elixir"
  ecr_address               = var.ecr_address

  tags = merge(local.common_tags, { "NodeClass" = "elixir" })
}

module "nomad_clients_rabbitmq" {
  source = "./modules/nomad-clients-rabbitmq"

  aws_region         = var.region
  ami                = var.ami
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  nomad_client_rabbit_min_size         = var.nomad_client_rabbit_min_size
  nomad_client_rabbit_max_size         = var.nomad_client_rabbit_max_size
  nomad_client_rabbit_desired_capacity = var.nomad_client_rabbit_desired_capacity

  nomad_dc             = "dc1"
  nomad_join_tag_key   = "nomad_ec2_join"
  nomad_join_tag_value = "nomad"

  nomad_client_rabbit_instance_type = var.nomad_client_rabbit_instance_type
  consul_join_tag_key               = "consul_ec2_join"
  consul_join_tag_value             = "consul"

  alb_client_target_groups = module.client_alb.alb_client_target_groups
  ec2_security_group_id    = module.firewall.ec2_security_group_id

  route_53_resolver_address = var.route_53_resolver_address
  node_class                = "rabbit"
  ecr_address               = var.ecr_address

  tags = merge(local.common_tags, { "NodeClass" = "rabbitmq" })
}

module "nomad_clients_apm" {
  source = "./modules/nomad-clients-apm"

  aws_region         = var.region
  ami                = var.ami
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  nomad_client_apm_min_size         = var.nomad_client_apm_min_size
  nomad_client_apm_max_size         = var.nomad_client_apm_max_size
  nomad_client_apm_desired_capacity = var.nomad_client_apm_desired_capacity

  nomad_dc             = "dc1"
  nomad_join_tag_key   = "nomad_ec2_join"
  nomad_join_tag_value = "nomad"

  nomad_client_apm_instance_type = var.nomad_client_apm_instance_type
  consul_join_tag_key            = "consul_ec2_join"
  consul_join_tag_value          = "consul"

  alb_client_target_groups = module.client_alb.alb_client_target_groups
  ec2_security_group_id    = module.firewall.ec2_security_group_id

  route_53_resolver_address = var.route_53_resolver_address
  node_class                = "apm"
  ecr_address               = var.ecr_address

  tags = merge(local.common_tags, { "NodeClass" = "apm" })
}

module "nomad_clients_traefik" {
  source = "./modules/nomad-clients-traefik"

  aws_region         = var.region
  ami                = var.ami
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  nomad_client_traefik_min_size         = var.nomad_client_traefik_min_size
  nomad_client_traefik_max_size         = var.nomad_client_traefik_max_size
  nomad_client_traefik_desired_capacity = var.nomad_client_traefik_desired_capacity

  nomad_dc             = "dc1"
  nomad_join_tag_key   = "nomad_ec2_join"
  nomad_join_tag_value = "nomad"

  nomad_client_traefik_instance_type = var.nomad_client_traefik_instance_type
  consul_join_tag_key                = "consul_ec2_join"
  consul_join_tag_value              = "consul"

  alb_client_target_groups = module.client_alb.alb_client_target_groups
  ec2_security_group_id    = module.firewall.ec2_security_group_id

  route_53_resolver_address = var.route_53_resolver_address
  node_class                = "traefik"
  ecr_address               = var.ecr_address

  tags = merge(local.common_tags, { "NodeClass" = "traefik" })
}

module "nomad_clients_celery" {
  source = "./modules/nomad-clients-celery"

  aws_region         = var.region
  ami                = var.ami
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  nomad_client_celery_min_size         = var.nomad_client_celery_min_size
  nomad_client_celery_max_size         = var.nomad_client_celery_max_size
  nomad_client_celery_desired_capacity = var.nomad_client_celery_desired_capacity

  nomad_dc             = "dc1"
  nomad_join_tag_key   = "nomad_ec2_join"
  nomad_join_tag_value = "nomad"

  nomad_client_celery_instance_type = var.nomad_client_celery_instance_type
  consul_join_tag_key               = "consul_ec2_join"
  consul_join_tag_value             = "consul"

  alb_client_target_groups = module.client_alb.alb_client_target_groups
  ec2_security_group_id    = module.firewall.ec2_security_group_id

  route_53_resolver_address = var.route_53_resolver_address
  node_class                = "celery"
  ecr_address               = var.ecr_address

  tags = merge(local.common_tags, { "NodeClass" = "celery" })
}

module "nomad_clients_datastore" {
  source = "./modules/nomad-clients-datastore"

  aws_region         = var.region
  ami                = var.ami
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  nomad_client_datastore_min_size         = var.nomad_client_datastore_min_size
  nomad_client_datastore_max_size         = var.nomad_client_datastore_max_size
  nomad_client_datastore_desired_capacity = var.nomad_client_datastore_desired_capacity

  nomad_dc             = "dc1"
  nomad_join_tag_key   = "nomad_ec2_join"
  nomad_join_tag_value = "nomad"

  nomad_client_datastore_instance_type = var.nomad_client_datastore_instance_type
  consul_join_tag_key                  = "consul_ec2_join"
  consul_join_tag_value                = "consul"

  alb_client_target_groups = module.client_alb.alb_client_target_groups
  ec2_security_group_id    = module.firewall.ec2_security_group_id

  route_53_resolver_address = var.route_53_resolver_address
  node_class                = "datastore"
  ecr_address               = var.ecr_address

  tags = merge(local.common_tags, { "NodeClass" = "datastore" })
}

# ==============================================================================
# STORAGE INFRASTRUCTURE
# ==============================================================================

module "itsy_storage" {
  source = "./modules/itsy_storage"

  itsy_web_bucket   = var.itsy_web_bucket
  itsy_media_bucket = var.itsy_media_bucket

  region = var.region

  django_static_public_prefix = var.django_static_public_prefix
  django_media_public_prefix  = var.django_media_public_prefix
  elixir_static_public_prefix = var.elixir_static_public_prefix
  elixir_media_public_prefix  = var.elixir_media_public_prefix

  tags = local.common_tags
}

# ==============================================================================
# DATABASE INFRASTRUCTURE
# ==============================================================================

module "itsy_postgres" {
  source = "./modules/postgres"

  db_subnet_group_name       = module.vpc.database_subnet_group
  postgres_security_group_id = module.firewall.postgres_security_group_id
  
  tags = local.common_tags
}
