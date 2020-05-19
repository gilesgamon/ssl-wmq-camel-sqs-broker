module "dynamodb_table" {
  source                       = "git::https://github.com/cloudposse/terraform-aws-dynamodb.git?ref=master"
  namespace                    = "eg"
  stage                        = local.environment
  name                         = "mq_test"
  hash_key                     = "AwsSqsMessageId"
  autoscale_write_target       = 50
  autoscale_read_target        = 50
  autoscale_min_read_capacity  = 150
  autoscale_max_read_capacity  = 1000
  autoscale_min_write_capacity = 50
  autoscale_max_write_capacity = 100
  enable_autoscaler            = "true"
  ttl_attribute                = 60
}