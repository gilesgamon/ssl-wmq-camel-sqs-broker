## IAM Role Policy that allows access to SQS from ECS task (docker instance)
resource "aws_iam_role_policy" "this" {
  name = "${var.name}-service"
  role = aws_iam_role.this.id

  lifecycle {
    create_before_destroy = true
  }
  policy = file("policies/task_policy.json")
}

resource "aws_iam_role" "this" {
  name = "${var.name}_role"

  assume_role_policy = file("policies/task_trust.json")
  }