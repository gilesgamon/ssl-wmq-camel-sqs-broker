resource "aws_iam_role" "ecs-instance-role" {
    name                = "ecs-instance-role"
    path                = "/"
    assume_role_policy  = file("policies/task_trust.json")
}

resource "aws_iam_role_policy_attachment" "ecs-instance-role-attachment" {
    role       = aws_iam_role.ecs-instance-role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs-instance-profile" {
    name = "ecs-instance-profile"
    path = "/"
    role = aws_iam_role.ecs-instance-role.id
    provisioner "local-exec" {
      command = "sleep 10"
    }
}

## IAM Role Policy that allows access to SQS
resource "aws_iam_role_policy" "camel_ecs_sqs" {
  name = "camel_ecs_sqs-role-policy"
  role = aws_iam_role.ecs-instance-role.id

  lifecycle {
    create_before_destroy = true
  }
  policy = file("policies/task_policy.json")
}

## IAM Role Policy that allows access to CloudWatch
resource "aws_iam_role_policy" "camel_ecs_cw" {
  name = "camel_ecs_cw-role-policy"
  role = aws_iam_role.ecs-instance-role.id

  lifecycle {
    create_before_destroy = true
  }
  policy = file("policies/ecs_cloud_watch_log.json")
}
