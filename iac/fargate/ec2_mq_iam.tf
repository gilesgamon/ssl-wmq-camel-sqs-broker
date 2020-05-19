resource "aws_iam_role" "ec2_mq" {
  name = "ec2_mq_instance_role"
  assume_role_policy = file("policies/ec2-trust.json")
}

resource "aws_iam_instance_profile" "ec2_mq_profile" {
  name = "ec2_mq_instance_profile"
  role = aws_iam_role.ec2_mq.name
}

resource "aws_iam_role_policy_attachment" "ecs_ec2_role" {
  role = aws_iam_role.ec2_mq.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ecs_ec2_cloudwatch_role" {
  role = aws_iam_role.ec2_mq.id
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_role_policy" "ec2_to_ecr" {
  name = "ec2_to_ecr"
  role = aws_iam_role.ec2_mq.id

  lifecycle {
    create_before_destroy = true
  }
  policy = file("policies/ec2-ecr-role.json")
}