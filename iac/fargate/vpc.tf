module "camel_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "camel-vpc"
  cidr = "10.1.0.0/16"

  azs             = ["${var.region}a", "${var.region}b", "${var.region}c"]
  public_subnets  = ["10.1.101.0/24", "10.1.102.0/24", "10.1.103.0/24"]
  private_subnets = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]

  single_nat_gateway        = true
  enable_nat_gateway        = true
  enable_dynamodb_endpoint  = true

  tags = {
  	Terraform   = "true"
  	Environment = "dev"
  }
}

resource "aws_security_group" "mqtls" {
  name        = "tf-mqtls"
  description = "Allow MQ TLS Traffic"
  vpc_id      = module.camel_vpc.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = 22
    to_port         = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    protocol        = "tcp"
    from_port       = 1414
    to_port         = 1414
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Camel to MQ"
    }
}

resource "aws_security_group" "ecs_tasks" {
  name        = "tf-ecs-tasks"
  description = "ECS Tasks outbound only"
  vpc_id      = module.camel_vpc.vpc_id

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Camel to MQ"
    }
}