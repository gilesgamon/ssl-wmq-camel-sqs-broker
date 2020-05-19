resource "aws_cloudwatch_log_group" "ecs_camel" {
  name                  = "/aws/ecs/tasks/ecs_camel"
  retention_in_days     = var.log_retention
}

module "ecs" {
  source                = "terraform-aws-modules/ecs/aws"
  name                  = local.name
}

resource "aws_ecs_service" "ecs_camel" {
  name                  = local.name
  cluster               = module.ecs.this_ecs_cluster_id
  task_definition       = aws_ecs_task_definition.ecs_camel.arn
  network_configuration { 
        subnets         = module.camel_vpc.private_subnets
        security_groups = [ aws_security_group.ecs_tasks.id ]
      }

  desired_count                      = var.camel_count
  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 0
  launch_type           = "FARGATE"

}
