variable "vpc_id" {
  description = "The ID which we'll chuck our ECS into - temp measure - self provision later"
  type        = string
  default	  = "vpc-810922e7"
}

variable "ecs_cluster_name" {
  description = "The name of the Amazon ECS cluster."
  default = "camel-broker"
}

variable "region" {
  description = "AWS region"
  default = "eu-west-1"
}

########################### Autoscale Config ################################

variable "max_instance_size" {
  description = "Maximum number of instances in the cluster"
  default = "3"
}

variable "min_instance_size" {
  description = "Minimum number of instances in the cluster"
  default = "1"
}

variable "desired_capacity" {
  description = "Desired number of instances in the cluster"
  default = "1"
}

variable "key_pair_name" {
  description = "for ssh"
  default = "giles"
}
