# Function to handle user facing RESTful request & send to SQS

data "archive_file" "rest_handler" {
  type = "zip"
  source_file = "lambda/restHandler.js"
  output_path = "lambda/restHandler.zip"
}

resource "aws_lambda_function" "rest_handler_test_function" {
  filename = data.archive_file.rest_handler.output_path
  function_name = "rest_handler_test_function"
  role = aws_iam_role.rest_handler_role.arn
  handler = "restHandler.handler"
  runtime = "nodejs12.x"
  timeout = 30
  source_code_hash = data.archive_file.rest_handler.output_base64sha256
  publish = true
  environment {
    variables = {
      REGION = var.region
      SQS_REQUEST_QUEUE_NAME = "https://sqs.${var.region}.amazonaws.com/${var.account_id}/sqs_request_1"
      TABLE_NAME = "gg_mq_test"
    }
  }
}

resource "aws_iam_role" "rest_handler_role" {
  name = "rest-handler-role"
  assume_role_policy = file("policies/rest-handler-role.json")
}

resource "aws_iam_role_policy" "rest_handler_role" {
  name = "rest-handler-role-policy"
  role = aws_iam_role.rest_handler_role.id

  lifecycle {
    create_before_destroy = true
  }
  policy = file("policies/rest-handler-policy.json")
}

# Function to take SQS response and add to DynamoDB table

data "archive_file" "sqsToDdb" {
  type = "zip"
  source_file = "lambda/sqsToDdb.js"
  output_path = "lambda/sqsToDdb.zip"
}

resource "aws_lambda_function" "mq_test_function" {
  filename = data.archive_file.sqsToDdb.output_path
  function_name = "mq_test_function"
  role = aws_iam_role.sqs_to_ddb_role.arn
  handler = "sqsToDdb.handler"
  runtime = "nodejs12.x"
  timeout = 30
  source_code_hash = data.archive_file.sqsToDdb.output_base64sha256
  publish = true
  environment {
    variables = {
      REGION = var.region
      SQS_RESPONSE_QUEUE_NAME = "https://sqs.${var.region}.amazonaws.com/${var.account_id}/sqs_response_1"
      TABLE_NAME = "gg_mq_test"
    }
  }
}

resource "aws_lambda_event_source_mapping" "mq_test_function" {
  event_source_arn = aws_sqs_queue.mqToSqsQueue.arn
  function_name    = aws_lambda_function.mq_test_function.arn
}

resource "aws_sqs_queue" "SqsToMqQueue" {
  name                      = "sqs_request_1"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 60
  receive_wait_time_seconds = 10
}

resource "aws_sqs_queue" "mqToSqsQueue" {
  name                      = "sqs_response_1"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 60
  receive_wait_time_seconds = 10
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

# Permission for the Gateway to invoke the Lambda
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rest_handler_test_function.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${var.region}:${var.account_id}:${aws_api_gateway_rest_api.rest_handler.id}/*/${aws_api_gateway_method.rest_handler_method.http_method}/${aws_api_gateway_resource.rest_handler_resource.path_part}"
}
