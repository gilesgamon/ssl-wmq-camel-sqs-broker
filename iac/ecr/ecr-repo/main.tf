#
# ECR Resources
#
resource "aws_ecr_repository" "default" {
  name = var.repository_name
}

resource "aws_ecr_lifecycle_policy" "default" {
  repository = aws_ecr_repository.default.name
  policy     = file("${path.module}/templates/default-lifecycle-policy.json.tpl")
}

resource "aws_ecr_repository_policy" "default" {
  repository = aws_ecr_repository.default.name

  policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "new policy",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "ecr:BatchGetImage",
        		"ecr:DescribeImages",
        		"ecr:DescribeRepositories",
        		"ecr:GetDownloadUrlForLayer",
        		"ecr:GetLifecyclePolicy",
        		"ecr:ListImages"
            ]
        }
    ]
}
EOF
}