resource "aws_ecs_task_definition" "ecs_camel" {
  family                  = local.name
  container_definitions   = "[${module.camel-container.json_map}]"
  requires_compatibilities= ["FARGATE"]
  task_role_arn				    = aws_iam_role.ecs_camel.arn
  execution_role_arn		  = aws_iam_role.ecs_camel.arn
  network_mode				    = "awsvpc"
  cpu						          = 256
  memory					        = 512
  depends_on              = [ aws_instance.docker_for_mq, aws_sqs_queue.SqsToMqQueue, aws_sqs_queue.mqToSqsQueue ]
}

resource "aws_iam_role_policy" "ecs_camel" {
  name = "${local.name}-service"
  role = aws_iam_role.ecs_camel.id

  lifecycle {
    create_before_destroy = true
  }
  policy = file("policies/task_policy.json")
}

resource "aws_iam_role" "ecs_camel" {
  name = "${local.name}_role"

  assume_role_policy = file("policies/task_trust.json")
}
