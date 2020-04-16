locals {
  name        = var.ecs_cluster_name
  environment = "dev"

  # This is the convention we use to know what belongs to each other
  ec2_resources_name = "${local.name}-${local.environment}"
}

#----- ECS --------
module "ecs" {
  source = "./ecs"
  name   = local.name
}

module "ec2-profile" {
  source = "./ecs-instance-profile"
  name   = local.name
}

#----- ECS  Services--------

module "camel-broker" {
  source     = "./ecs-service"
  name       = local.name
  cluster_id = module.ecs.this_ecs_cluster_id
  image      = "${var.account_id}.dkr.ecr.eu-west-1.amazonaws.com/camel-broker:latest"
  region     = var.region
}

#----- ECS  Resources--------

data "aws_subnet_ids" "gifted_vpc" {
  vpc_id = var.vpc_id
}

data "aws_security_groups" "gifted_sgs" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}
