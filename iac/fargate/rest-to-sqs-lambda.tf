# Function to handle user facing RESTful request & send to SQS
data "archive_file" "rest_to_sqs" {
  type = "zip"
  source_file = "lambda/restHandler.js"
  output_path = "lambda/restHandler.zip"
}

resource "aws_lambda_function" "rest_to_sqs" {
  filename = data.archive_file.rest_to_sqs.output_path
  function_name = "rest_to_sqs"
  role = aws_iam_role.rest_to_sqs_role.arn
  handler = "restHandler.handler"
  runtime = "nodejs12.x"
  timeout = 30
  source_code_hash = data.archive_file.rest_to_sqs.output_base64sha256
  publish = true
  environment {
    variables = {
      REGION = var.region
      SQS_REQUEST_QUEUE_NAME = "https://sqs.${var.region}.amazonaws.com/${var.account_id}/${var.request_queue_name}"
      TABLE_NAME = module.dynamodb_table.table_name
    }
  }
}

resource "aws_cloudwatch_log_group" "rest_to_sqs" {
  name                  = "/aws/lambda/rest_to_sqs"
  retention_in_days     = var.log_retention
}

resource "aws_iam_role" "rest_to_sqs_role" {
  name = "rest-to-sqs-role"
  assume_role_policy = file("policies/rest-to-sqs-role.json")
}

resource "aws_iam_role_policy" "rest_to_sqs_role" {
  name = "rest-to-sqs-role-policy"
  role = aws_iam_role.rest_to_sqs_role.id

  lifecycle {
    create_before_destroy = true
  }
  policy = file("policies/rest-to-sqs-policy.json")
}