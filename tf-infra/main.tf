module "ecr" {
  source   = "./modules/ecr"
  ecr_name = var.ecr_name
}

module "vpc" {
  source      = "./modules/vpc"
  depends_on  = [module.ecr]
  environment = var.environment

  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
  public_subnets     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  database_subnets   = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]

}

module "firewall" {
  source       = "./modules/firewall"
  whitelist_ip = "0.0.0.0/0"
  vpc_id       = module.vpc.vpc_id
  vpc_cidr     = "10.0.0.0/16"
}

module "server_alb" {
  source = "./modules/server_alb"

  vpc_id                       = module.vpc.vpc_id
  public_subnet_ids            = module.vpc.public_subnet_ids
  whitelist_ip                 = "0.0.0.0/0"
  alb_certificate_arn          = var.alb_certificate_arn
  nomad_address                = var.nomad_host_name
  consul_address               = var.consul_host_name
  server_alb_security_group_id = module.firewall.server_alb_security_group_id
}

module "client_alb" {
  source = "./modules/client_alb"

  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids

  client_alb_security_group_id = module.firewall.client_alb_security_group_id
  alb_certificate_arn          = var.alb_certificate_arn
  host_address_list            = var.client_host_adress_list
  alb_domain_certificate_arns   = var.alb_domain_certificate_arns

}

module "consul_servers" {

  # add vpc module as dependency
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

  cluster_tags = { "consul-cluster" = "consul-cluster" }

  consul_server_instance_type = var.consul_server_instance_type
  consul_bootstrap_expect     = var.consul_server_desired_capacity
  consul_join_tag_value       = "consul"
  consul_join_tag_key         = "consul_ec2_join"

}

module "nomad_servers" {

  # add vpc module as dependency
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

  nomad_dc                   = "dc1"
  cluster_tags               = { "nomad-cluster" = "nomad-cluster" }
  nomad_join_tag_value       = "nomad"
  nomad_bootstrap_expect     = 1
  nomad_gossip_encrypt_key   = "z8geXx7U+JPk6u/vlBRDhh81h5W12AXBN+7AUo5eXMI="
  nomad_acl_bootstrap_token  = "5b43c18d-d1f7-a854-d2ad-6149080a1dd6"
  nomad_server_instance_type = var.nomad_server_instance_type
  nomad_join_tag_key         = "nomad_ec2_join"

  consul_join_tag_value = "consul"
  consul_join_tag_key   = "consul_ec2_join"

}

module "nomad_clients-django" {

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

  route_53_resolver_address = "10.0.0.2"
  node_class                = "django"
  ecr_address               = var.ecr_address

}

module "nomad_clients-elixir" {

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

  route_53_resolver_address = "10.0.0.2"
  node_class                = "elixir"
  ecr_address               = var.ecr_address

}

module "nomad_clients-rabbitmq" {

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

  route_53_resolver_address = "10.0.0.2"
  node_class                = "rabbit"
  ecr_address               = var.ecr_address

}

module "nomad_clients-apm" {

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

  route_53_resolver_address = "10.0.0.2"
  node_class                = "apm"
  ecr_address               = var.ecr_address

}

module "nomad_clients-traefik" {

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

  route_53_resolver_address = "10.0.0.2"
  node_class                = "traefik"
  ecr_address               = var.ecr_address

}

module "nomad_clients-celery" {

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

  route_53_resolver_address = "10.0.0.2"
  node_class                = "traefik"
  ecr_address               = var.ecr_address

}

module "itsy_storage" {
  # s3 buckets and cloudfront
  source = "./modules/itsy_storage"

  itsy_web_bucket   = var.itsy_web_bucket
  itsy_media_bucket = var.itsy_media_bucket

  region = var.region

  django_static_public_prefix = var.django_static_public_prefix
  django_media_public_prefix  = var.django_media_public_prefix
  elixir_static_public_prefix = var.elixir_static_public_prefix
  elixir_media_public_prefix  = var.elixir_media_public_prefix



}

module "nomad_clients-datastore" {

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

  route_53_resolver_address = "10.0.0.2"
  node_class                = "datastore"
  ecr_address               = var.ecr_address

}

module "itsy_postgres" {

  source = "./modules/postgres"

  db_subnet_group_name = module.vpc.database_subnet_group
  postgres_security_group_id = module.firewall.postgres_security_group_id
}