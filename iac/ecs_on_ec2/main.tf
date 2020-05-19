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

#----- ECS Resources--------

data "aws_subnet_ids" "gifted_vpc" {
  vpc_id = module.camel_vpc.vpc_id
}

# Traffic for admin access
resource "aws_security_group" "ecs_tasks_ssh" {
  name        = "tf-ecs-ssh"
  description = "allow ssh access for Giles"
  vpc_id      = module.camel_vpc.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = 22
    to_port         = 22
    cidr_blocks     = local.admins
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "MISP Admin ssh"
    }
}

resource "aws_security_group" "ecs_tasks" {
  name        = "tf-ecs-tasks"
  description = "allow inbound access from Camel/Admins only"
  vpc_id      = module.camel_vpc.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = 1414
    to_port         = 1414
  }

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = local.admins
  }

  ingress {
    protocol    = "tcp"
    from_port   = 9443
    to_port     = 9443
    cidr_blocks = local.admins
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Camel (and Admin) to MQ"
    }
}