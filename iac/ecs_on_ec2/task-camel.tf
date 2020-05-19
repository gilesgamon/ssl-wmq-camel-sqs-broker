resource "aws_cloudwatch_log_group" "ecs_camel" {
  name              = "/aws/ecs/tasks/ecs_camel"
  retention_in_days = 1
}

resource "aws_ecs_task_definition" "ecs_camel" {
  family = local.name
  task_role_arn = aws_iam_role.ecs_camel.arn

  container_definitions = <<EOF
[
  {
    "name": "ecs_camel",
    "image": "${var.account_id}.dkr.ecr.eu-west-1.amazonaws.com/camel-broker:latest",
    "cpu": 0,
    "memory": 256,
    "environment": [ {"name" : "MQ_HOSTNAME", "value": "${var.mq_url}" } ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "${var.region}",
        "awslogs-group": "/aws/ecs/tasks/ecs_camel",
        "awslogs-stream-prefix": "complete-ecs"
      }
    }
  }
]
EOF
}

resource "aws_ecs_service" "ecs_camel" {
  name            = local.name
  cluster         = module.ecs.this_ecs_cluster_id
  task_definition = aws_ecs_task_definition.ecs_camel.arn

  desired_count                      = var.camel_count
  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 0

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
