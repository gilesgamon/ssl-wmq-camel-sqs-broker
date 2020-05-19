variable "vpc_id" {
  description = "The ID which we'll chuck our ECS into - temp measure - self provision later"
  type        = string
  default	  = "vpc-810922e7"
}

variable "account_id" {
  description = "AWS Account Identifier (number)"
  type = string
  default = "272154369820"
}

variable "ecs_cluster_name" {
  description = "The name of the Amazon ECS cluster."
  type = string
  default = "camel-broker"
}

variable "region" {
  description = "AWS region"
  type = string
  default = "eu-west-1"
}

provider "aws" {
  region     = var.region
}

###### MQ Service

variable "mq_count" {
  description = "Desired number of ECS tasks running MQ"
  type        = string
  default     = "1"
}

variable "mq_url" {
  description = "DNS URL for the MQ service"
  type        = string
  default     = "mq.lsiarchi.consulting"
}

variable "mq_zone_id" {
  description = "DNS Zone ID to update"
  type        = string
  default     = "Z3UWPNI3OLXJB8"
}

##### Camel Service

variable "camel_count" {
  description = "Desired number of ECS tasks running Camel"
  type        = string
  default     = "2"
}

########################### Autoscale Config ################################

variable "instance_type" {
  description = "The AWS instance type t2.micro for example"
  type = string
  #default = "c5.2xlarge"
  default = "t2.micro"
}

variable "max_instance_size" {
  description = "Maximum number of instances in the cluster"
  type = string
  default = "3"
}

variable "min_instance_size" {
  description = "Minimum number of instances in the cluster"
  type = string
  default = "1"
}

variable "desired_capacity" {
  description = "Desired number of instances in the cluster"
  type = string
  default = "1"
}

variable "key_pair_name" {
  description = "for ssh"
  type = string
  default = "giles"
}

# Lambda


##### Admin IP addresses #####

variable "admin1" {
  description = "CIDR of recognised Admin #1"
  type        = string
  default     = "84.64.217.188/32"
}

variable "admin2" {
  description = "CIDR of recognised Admin #2"
  type        = string
  default     = "2.24.187.231/32"
}

locals {
  admins     = [var.admin1, var.admin2]
}