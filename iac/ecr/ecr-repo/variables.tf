variable "repository_name" {}

variable "attach_lifecycle_policy" {
  default = true
}

variable "lifecycle_policy" {
  default = ""
}

variable "region" {
	default = "eu-west-1"
}