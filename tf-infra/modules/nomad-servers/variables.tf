variable "vpc_id" {} 
variable "private_subnet_ids" {}
variable "public_subnet_ids" {}

variable "ami" {}
variable "nomad_dc" {}
variable "aws_region" {}
variable "nomad_bootstrap_expect" {}
variable "nomad_gossip_encrypt_key" {}
variable "nomad_join_tag_value" {}
variable "nomad_join_tag_key" {}
variable "nomad_acl_bootstrap_token" {}
variable "cluster_tags" {}
variable "nomad_server_instance_type" {}

variable "consul_join_tag_key" {}
variable "consul_join_tag_value" {}


variable "alb_server_target_groups" {}
variable "ec2_security_group_id" {}

variable "nomad_server_min_size" {}
variable "nomad_server_max_size" {}
variable "nomad_server_desired_capacity" {}