module "ecr-repository" {
  source = "./ecr-repo"

  repository_name = "camel-broker"
  attach_lifecycle_policy = true
}
