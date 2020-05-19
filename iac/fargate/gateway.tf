resource "aws_api_gateway_rest_api" "rest_to_sqs" {
  name = "RESTtoMQ_Arcot_PoC"
  description = "API to send to MQ connected source"
}

resource "aws_api_gateway_resource" "rest_to_sqs_resource" {
  rest_api_id = aws_api_gateway_rest_api.rest_to_sqs.id
  parent_id   = aws_api_gateway_rest_api.rest_to_sqs.root_resource_id
  path_part   = "messages"
}

resource "aws_api_gateway_method" "rest_to_sqs_method" {
  rest_api_id = aws_api_gateway_rest_api.rest_to_sqs.id
  resource_id = aws_api_gateway_resource.rest_to_sqs_resource.id
  http_method = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "rest_to_sqs_method-integration" {
  rest_api_id = aws_api_gateway_rest_api.rest_to_sqs.id
  resource_id = aws_api_gateway_resource.rest_to_sqs_resource.id
  http_method = aws_api_gateway_method.rest_to_sqs_method.http_method
  type        = "AWS_PROXY"
  uri         = aws_lambda_function.rest_to_sqs.invoke_arn
  integration_http_method = "POST"
}

resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_method.rest_to_sqs_method,
    aws_api_gateway_integration.rest_to_sqs_method-integration
  ]
  rest_api_id = aws_api_gateway_rest_api.rest_to_sqs.id
}

resource "aws_api_gateway_stage" "test" {
  stage_name    = local.environment
  rest_api_id   = aws_api_gateway_rest_api.rest_to_sqs.id
  deployment_id = aws_api_gateway_deployment.deployment.id
}

resource "aws_api_gateway_method_settings" "s" {
  rest_api_id = aws_api_gateway_rest_api.rest_to_sqs.id
  stage_name  = aws_api_gateway_stage.test.stage_name
  method_path = "${aws_api_gateway_resource.rest_to_sqs_resource.path_part}/${aws_api_gateway_method.rest_to_sqs_method.http_method}"

  settings {
    metrics_enabled = true
    logging_level   = "INFO"
  }
}

output "dev_url" {
  value = "https://${aws_api_gateway_deployment.deployment.rest_api_id}.execute-api.${var.region}.amazonaws.com/${aws_api_gateway_stage.test.stage_name}"
}

resource "aws_api_gateway_account" "demo" {
  cloudwatch_role_arn = aws_iam_role.cloudwatch.arn
}

resource "aws_iam_role" "cloudwatch" {
  name = "api_gateway_cloudwatch_global"

  assume_role_policy = file("policies/cloudWatch-role.json")
}

resource "aws_iam_role_policy" "cloudwatch" {
  name = "default"
  role = aws_iam_role.cloudwatch.id

  policy = file("policies/apiGateway-policy.json")
}

resource "aws_cloudwatch_log_group" "noise_lg" {
  name                  = "/aws/apigateway/welcome"
  retention_in_days     = var.log_retention
}

# Permission for the Gateway to invoke the Lambda
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rest_to_sqs.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${var.region}:${var.account_id}:${aws_api_gateway_rest_api.rest_to_sqs.id}/*/${aws_api_gateway_method.rest_to_sqs_method.http_method}/${aws_api_gateway_resource.rest_to_sqs_resource.path_part}"
}

#resource "aws_cloudwatch_log_group" "api_gw_logs" {
#  name                  = "API-Gateway-Execution-Logs_${aws_api_gateway_deployment.deployment.rest_api_id}/${aws_api_gateway_stage.test.stage_name}"
#  retention_in_days     = var.log_retention
#}