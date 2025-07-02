variable "region" {}
variable "environment" {}
variable "aws_profile" {}

variable "alb_certificate_arn" {}
variable "alb_domain_certificate_arns" {}
variable "client_host_adress_list" {}
variable "nomad_host_name" {}
variable "consul_host_name" {}
variable "ami" {}
variable "ecr_address" {}
variable "image_mutability" {}
variable "ecr_name" {}

variable "consul_server_min_size" {}
variable "consul_server_max_size" {}
variable "consul_server_desired_capacity" {}

variable "nomad_server_min_size" {}
variable "nomad_server_max_size" {}
variable "nomad_server_desired_capacity" {}

variable "nomad_client_apm_min_size" {}
variable "nomad_client_apm_max_size" {}
variable "nomad_client_apm_desired_capacity" {}

variable "nomad_client_elixir_min_size" {}
variable "nomad_client_elixir_max_size" {}
variable "nomad_client_elixir_desired_capacity" {}

variable "nomad_client_django_min_size" {}
variable "nomad_client_django_max_size" {}
variable "nomad_client_django_desired_capacity" {}

variable "nomad_client_celery_min_size" {}
variable "nomad_client_celery_max_size" {}
variable "nomad_client_celery_desired_capacity" {}

variable "nomad_client_rabbit_min_size" {}
variable "nomad_client_rabbit_max_size" {}
variable "nomad_client_rabbit_desired_capacity" {}

variable "nomad_client_traefik_min_size" {}
variable "nomad_client_traefik_max_size" {}
variable "nomad_client_traefik_desired_capacity" {}

variable "nomad_client_datastore_min_size" {}
variable "nomad_client_datastore_max_size" {}
variable "nomad_client_datastore_desired_capacity" {}


variable "itsy_web_bucket" {}
variable "itsy_media_bucket" {}

variable "django_static_public_prefix" {}
variable "django_media_public_prefix" {}

variable "elixir_static_public_prefix" {}
variable "elixir_media_public_prefix" {}

variable "consul_server_instance_type" {}
variable "nomad_server_instance_type" {}

variable "nomad_client_apm_instance_type" {}
variable "nomad_client_elixir_instance_type" {}
variable "nomad_client_django_instance_type" {}
variable "nomad_client_celery_instance_type" {}
variable "nomad_client_rabbit_instance_type" {}
variable "nomad_client_traefik_instance_type" {}
variable "nomad_client_datastore_instance_type" {}



/* variable "vpc_id" {} 
variable "private_subnet_ids" {}
variable "alb_certificate_arn" {} */
/* variable "whitelist_ip" {} */

/* variable "app_name" {}
variable "cidr_block" {}
variable "private_subnets" {}
variable "public_subnets" {}
variable "availability_zones" {}
variable "db_subnet_group" {}
variable "db_security_group" {}
variable "cluster_identifier" {}
variable "engine_version" {}
variable "db_cloudwatch_log_type" {}
variable "max_scaling" {}
variable "min_scaling" {}
variable "cluster_id" {}
variable "subnet_name" {}
variable "node_type" {}
variable "nodes" {}
variable "log_type" {}
variable "environment" {}
variable "mongodb_security_group" {
  
}
variable "aws_profile" {
  description = "Profile that need to be used with AWS"
}
######################
#hashistack variables#
######################

variable "name" {
  description = "Used to name various infrastructure components"
}

variable "region" {
  description = "The AWS region to deploy to."
}

variable "whitelist_ip" {
  description = "IP to whitelist for the security groups (set 0.0.0.0/0 for world)"
}

variable "ami" {
}

variable "server_instance_type" {
  description = "The AWS instance type to use for servers."
}

variable "client_instance_type_stateless" {
}

variable "client_instance_type_elixir" {
}

variable "client_instance_type_stateful" {
}

variable "root_block_device_size" {
  description = "The volume size of the root block device."
  default     = 16
}

variable "key_name" {
  description = "Name of the SSH key used to provision EC2 instances."
}

variable "server_count" {
  description = "The number of servers to provision."
}

variable "client_count_elixir" {
  description = "The number of clients to provision."
}

variable "client_count_stateful" {
  description = "The number of clients to provision."
}

variable "client_count_stateless" {
  description = "The number of clients to provision."
}

variable "retry_join" {
  description = "Used by Consul to automatically form a cluster."
  type        = map(string)

  default = {
    provider  = "aws"
    tag_key   = "ConsulAutoJoin"
    tag_value = "auto-join"
  }
}

variable "nomad_binary" {
  description = "Used to replace the machine image installed Nomad binary."
}

variable "ecr_address" {
  description = "Address of ECR repository"
}

variable "nomad_client_stateless_node_class" {}
variable "nomad_client_elixir_node_class" {}
variable "nomad_client_stateful_node_class" {}


###################################
########## ECR Varaibles ##########
###################################

variable "ecr_name" {
  description = "The list of ecr names to create"
  type        = list(string)
  default     = null
}
variable "tags" {
  description = "The key-value maps for tagging"
  type        = map(string)
  default     = {}
}
variable "image_mutability" {
  description = "Provide image mutability"
  type        = string
  default     = "MUTABLE"
}

variable "encrypt_type" {
  description = "Provide type of encryption here"
  type        = string
  default     = "KMS"
}

################################
#### itsy web stack ############
################################
variable "bucket_name" {
  type = string
}

variable "django_static_public_prefix" {
  type = string
}

variable "django_media_public_prefix" {
  type = string
}

variable "elixir_static_public_prefix" {
  type = string
}

variable "elixir_media_public_prefix" {
  type = string
}

#################################
#######   Elastic ###############
#################################
variable "domain_name" {
  type        = string
  description = "name of Elasticsearch Domain"
}

variable "elasticsearch_version" {
  type        = string
  description = "Version of Elasticsearch to deploy"
}

variable "instance_type" {
  type        = string
  description = "Elasticsearch instance type for data nodes in the cluster"
}

variable "instance_count" {
  type        = number
  description = "Number of data nodes in the cluster"
}

variable "zone_awareness_enabled" {
  type        = bool
  description = "Enable zone awareness for Elasticsearch cluster"
}

variable "availability_zone_count" {
  type        = number
  description = "Number of Availability Zones for the domain to use."
}

variable "ebs_volume_size" {
  type        = number
  description = "EBS volumes for data storage in GB"
}

variable "ebs_volume_type" {
  type        = string
  description = "Storage type of EBS volumes"
}

variable "encrypt_at_rest_enabled" {
  type        = bool
  description = "Whether to enable encryption at rest"
}

variable "dedicated_master_enabled" {
  type        = bool
  description = "Indicates whether dedicated master nodes are enabled for the cluster"
}

variable "dedicated_master_count" {
  type        = number
  description = "Number of dedicated master nodes in the cluster"
}

variable "dedicated_master_type" {
  type        = string
  description = "Instance type of the dedicated master nodes in the cluster"
}

variable "node_to_node_encryption_enabled" {
  type        = bool
  description = "Whether to enable node-to-node encryption"
}

variable "es_security_group" {
  description = "postgres sql ingress ports"
}

#####################################
##### redis ######################
#################################

variable "redis_security_group_ports" {}


##############################
################ s3 ##########
##############################

variable "itsy_media_bucket" {} */