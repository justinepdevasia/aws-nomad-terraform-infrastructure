variable "vpc_id" {} 
variable "private_subnet_ids" {}
variable "public_subnet_ids" {}

variable "ami" {}
variable "aws_region" {}
variable "cluster_tags" {}

variable "consul_join_tag_value" {}
variable "consul_join_tag_key" {}
variable "consul_server_instance_type" {}
variable "consul_bootstrap_expect" {}

variable "alb_server_target_groups" {}
variable "ec2_security_group_id" {}

variable "consul_server_min_size" {}
variable "consul_server_max_size" {}
variable "consul_server_desired_capacity" {}

