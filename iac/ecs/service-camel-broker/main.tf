resource "aws_cloudwatch_log_group" "camel-broker" {
  name              = "camel-broker"
  retention_in_days = 1
}

resource "aws_ecs_task_definition" "camel-broker" {
  family = "camel-broker"
  task_role_arn = aws_iam_role.camel_ecs_sqs_role.arn

  container_definitions = <<EOF
[
  {
    "name": "camel-broker",
    "image": "272154369820.dkr.ecr.eu-west-1.amazonaws.com/camel-broker:latest",
    "cpu": 0,
    "memory": 256,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "eu-west-1",
        "awslogs-group": "camel-broker",
        "awslogs-stream-prefix": "complete-ecs"
      }
    }
  }
]
EOF
}

resource "aws_ecs_service" "camel-broker" {
  name = "camel-broker"
  cluster = var.cluster_id
  task_definition = aws_ecs_task_definition.camel-broker.arn

  desired_count = 1

  deployment_maximum_percent = 100
  deployment_minimum_healthy_percent = 0
}