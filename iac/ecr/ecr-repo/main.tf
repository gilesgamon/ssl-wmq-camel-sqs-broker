#
# ECR Resources
#
resource "aws_ecr_repository" "default" {
  name = var.repository_name
}

resource "aws_ecr_lifecycle_policy" "default" {
  repository = aws_ecr_repository.default.name
  policy     = file("${path.module}/policies/ecr_lifecycle_policy.json")
}

resource "aws_ecr_repository_policy" "default" {
  repository = aws_ecr_repository.default.name

  policy = file("${path.module}/policies/ecr_policy.json")

}