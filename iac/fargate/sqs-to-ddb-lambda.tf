# Function to take SQS response and add to DynamoDB table
data "archive_file" "sqsToDdb" {
  type = "zip"
  source_file = "lambda/sqsToDdb.js"
  output_path = "lambda/sqsToDdb.zip"
}

resource "aws_lambda_function" "sqs_to_ddb" {
  filename = data.archive_file.sqsToDdb.output_path
  function_name = "sqs_to_ddb"
  role = aws_iam_role.sqs_to_ddb_role.arn
  handler = "sqsToDdb.handler"
  runtime = "nodejs12.x"
  timeout = 30
  source_code_hash = data.archive_file.sqsToDdb.output_base64sha256
  publish = true
  environment {
    variables = {
      REGION = var.region
      SQS_RESPONSE_QUEUE_NAME = "https://sqs.${var.region}.amazonaws.com/${var.account_id}/${var.response_queue_name}"
      TABLE_NAME = module.dynamodb_table.table_name
    }
  }
}

resource "aws_cloudwatch_log_group" "sqs_to_ddb" {
  name                  = "/aws/lambda/sqs_to_ddb"
  retention_in_days     = var.log_retention
}

resource "aws_iam_role" "sqs_to_ddb_role" {
  name = "sqs-to-ddb-role"
  assume_role_policy = file("policies/sqs-to-ddb-role.json")
}

resource "aws_iam_role_policy" "sqs_to_ddb" {
  name = "sqs-to-ddb-policy"
  role = aws_iam_role.sqs_to_ddb_role.id

  lifecycle {
    create_before_destroy = true
  }
  policy = file("policies/sqs-to-ddb-policy.json")
}

resource "aws_lambda_event_source_mapping" "sqs_to_ddb" {
  event_source_arn = aws_sqs_queue.mqToSqsQueue.arn
  function_name    = aws_lambda_function.sqs_to_ddb.arn
}
