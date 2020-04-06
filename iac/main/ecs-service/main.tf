resource "aws_cloudwatch_log_group" "this" {
  name              = var.name
  retention_in_days = 1
}

resource "aws_ecs_task_definition" "this" {
  family = var.name
  task_role_arn = aws_iam_role.this.arn

  container_definitions = <<EOF
[
  {
    "name": "${var.name}",
    "image": "${var.image}",
    "cpu": 0,
    "memory": 256,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "${var.region}",
        "awslogs-group": "${var.name}",
        "awslogs-stream-prefix": "complete-ecs"
      }
    }
  }
]
EOF
}

resource "aws_ecs_service" "this" {
  name            = var.name
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.this.arn

  desired_count                      = 1
  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 0
}