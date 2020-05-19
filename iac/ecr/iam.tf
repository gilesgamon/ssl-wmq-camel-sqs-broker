resource "aws_iam_policy" "appDevOpsForECS" {
  name = "tf-AppDevOps-ECS-Role"
  description = "Terraform controlled role to grant AppDevOps Role sufficient permission to provision ECS for Camel to MQ gateway"

  lifecycle {
    create_before_destroy = true
  }
  policy = file("policies/AppDevOps_forECS.json")
}

resource "aws_iam_policy_attachment" "AppDevOps-Role-Attachment" {
	name = "role attachment AppDevOps-ECS"
	roles = ["LSI_Developer"]
	policy_arn = aws_iam_policy.appDevOpsForECS.arn
}
