variable "region" {
  description = "AWS region"
  type = string
  default = "eu-west-1"
}

provider "aws" {
  region     = var.region
}
