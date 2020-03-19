## IAM Role Policy that allows access to SQS from ECS task (docker instance)
resource "aws_iam_role_policy" "camel_ecs_sqs" {
  name = "camel_ecs_sqs"
  role = aws_iam_role.camel_ecs_sqs_role.id

  lifecycle {
    create_before_destroy = true
  }
  policy = file("policies/task_policy.json")
}

resource "aws_iam_role" "camel_ecs_sqs_role" {
  name = "camel_ecs_sqs_role"

  assume_role_policy = file("policies/task_trust.json")
  }