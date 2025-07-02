variable "cluster_id" {
  description = "Identification for cluster"
}

variable "subnet_name" {
  description = "Elastic cache subnet name"
}

variable "subnet_ids" {
  description = "ELastic cache subnet ID's"
}

variable "node_type" {
  description = "Type of Node of Elastic cache"
}

variable "nodes" {
  description = "No of nodes"
}

variable "log_type" {
  description = "types of logs"
}

variable "environment" {
  
}

variable "redis_security_group_ports" {}
variable "app_name" {}
variable "vpc_id" {}