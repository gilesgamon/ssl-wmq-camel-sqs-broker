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

variable "log_retention" {
  description   = "How long to we want to store all CloudWatch logs for"
  type          = string
  default       = "14"
}

###### MQ Service

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

##### SQS Service

variable "request_queue_name" {
  description  = "Name in SQS for outgoing requests"
  type         = string
  default      = "sqs_request_1"
}

variable "response_queue_name" {
  description  = "Name in SQS for outgoing responses"
  type         = string
  default      = "sqs_response_1"
}

##### Camel Service

variable "camel_count" {
  description = "Desired number of ECS tasks running Camel"
  type        = string
  default     = "3"
}

variable "instance_type" {
  description = "The AWS instance type t2.micro for example"
  type = string
  default = "t2.micro"
}

variable "key_pair_name" {
  description = "for ssh"
  type = string
  default = "giles"
}

# Lambda


# Fargate

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "1024"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "2048"
}

###################### Local setup

locals {
  name        = var.ecs_cluster_name
  environment = "dev"
}

