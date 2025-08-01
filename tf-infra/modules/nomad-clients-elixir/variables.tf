variable "vpc_id" {} 
variable "private_subnet_ids" {}

variable "ami" {}
variable "nomad_dc" {}
variable "aws_region" {}

variable "nomad_join_tag_value" {}
variable "nomad_join_tag_key" {}

variable "nomad_client_elixir_instance_type" {}

variable "consul_join_tag_key" {}
variable "consul_join_tag_value" {}


variable "alb_client_target_groups" {}
variable "ec2_security_group_id" {}

variable "route_53_resolver_address" {}
variable "node_class" {}
variable "ecr_address" {}

variable "nomad_client_elixir_min_size" {}
variable "nomad_client_elixir_max_size" {}
variable "nomad_client_elixir_desired_capacity" {}