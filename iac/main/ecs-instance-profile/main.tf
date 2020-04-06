resource "aws_iam_role" "this" {
  name = "${var.name}_ecs_instance_role"
  path = "/ecs/"

  assume_role_policy = file("policies/ecs_trust_policy.json")
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.name}_ecs_instance_profile"
  role = aws_iam_role.this.name
}

resource "aws_iam_role_policy_attachment" "ecs_ec2_role" {
  role = aws_iam_role.this.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ecs_ec2_cloudwatch_role" {
  role = aws_iam_role.this.id
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}
