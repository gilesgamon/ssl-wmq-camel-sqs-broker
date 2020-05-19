module "camel_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "camel-vpc"
  cidr = "10.1.0.0/16"

  azs             = ["${var.region}a", "${var.region}b", "${var.region}c"]
  public_subnets  = ["10.1.101.0/24", "10.1.102.0/24", "10.1.103.0/24"]
  private_subnets = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]

  single_nat_gateway        = true
  enable_nat_gateway        = true
#  enable_sqs_endpoint       = true
#  enable_apigw_endpoint     = true
#  enable_ecr_api_endpoint   = true
#  enable_ecs_agent_endpoint = true
#  enable_logs_endpoint      = true
  enable_dynamodb_endpoint  = true

  tags = {
  	Terraform   = "true"
  	Environment = "dev"
  }
}
