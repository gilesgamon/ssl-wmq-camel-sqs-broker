provider "aws" {
	region = var.region
	version = ">= 2.7.0"
}

provider "archive" {
	version = "~> 1.2"
}

provider "null" {
	version = "~> 2.1"
}

provider "template" {
	version = "~> 2.1"
}

provider "external" {
	version = "~> 1.2"
}