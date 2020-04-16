module "ecr-repository-ibm_mq_tls" {
  source = "./ecr-repo"

  repository_name = "ibm_mq_tls"
  attach_lifecycle_policy = true
}