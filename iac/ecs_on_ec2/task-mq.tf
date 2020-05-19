## MQ Task
resource "aws_cloudwatch_log_group" "ecs_mq" {
  name              = "/aws/ecs/tasks/ecs_mq"
  retention_in_days = 1
}

resource "aws_ecs_task_definition" "ecs_mq" {
  family = local.name
  task_role_arn = aws_iam_role.ecs_mq.arn

  container_definitions = <<EOF
[
  {
    "name": "ecs_mq",
    "image": "${var.account_id}.dkr.ecr.eu-west-1.amazonaws.com/ibm_mq_tls:latest",
    "cpu": 0,
    "memory": 256,
    "portMappings": [ { "hostPort": 1414, "containerPort": 1414, "protocol": "tcp" },
                      { "hostPort": 9443, "containerPort": 9443, "protocol": "tcp" } ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "${var.region}",
        "awslogs-group": "/aws/ecs/tasks/ecs_mq",
        "awslogs-stream-prefix": "complete-ecs"
      }
    }
  }
]
EOF
}

resource "aws_ecs_service" "ecs_mq" {
  name            = "ecs_mq"
  cluster         = module.ecs.this_ecs_cluster_id
  task_definition = aws_ecs_task_definition.ecs_mq.arn

  desired_count                      = var.mq_count
  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 0

#  load_balancer {
#    target_group_arn = aws_lb_target_group.mq.arn
#    container_name   = "ecs_mq"
#    container_port   = 1414
#  }
}

resource "aws_iam_role_policy" "ecs_mq" {
  name = "${local.name}-service"
  role = aws_iam_role.ecs_mq.id

  lifecycle {
    create_before_destroy = true
  }
  policy = file("policies/task_policy.json")
}

resource "aws_iam_role" "ecs_mq" {
  name = "ecs_mq_role"

  assume_role_policy = file("policies/task_trust.json")
}
