resource "aws_api_gateway_rest_api" "rest_handler" {
  name = "RESTfulAPI"
  description = "API to send to MQ connected source"
}

resource "aws_api_gateway_resource" "rest_handler_resource" {
  rest_api_id = aws_api_gateway_rest_api.rest_handler.id
  parent_id = aws_api_gateway_rest_api.rest_handler.root_resource_id
  path_part = "messages"
}

resource "aws_api_gateway_method" "rest_handler_method" {
  rest_api_id = aws_api_gateway_rest_api.rest_handler.id
  resource_id = aws_api_gateway_resource.rest_handler_resource.id
  http_method = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "rest_handler_method-integration" {
  rest_api_id = aws_api_gateway_rest_api.rest_handler.id
  resource_id = aws_api_gateway_resource.rest_handler_resource.id
  http_method = aws_api_gateway_method.rest_handler_method.http_method
  type = "AWS_PROXY"
  uri = aws_lambda_function.rest_handler_test_function.invoke_arn
  integration_http_method = "POST"
}

resource "aws_api_gateway_deployment" "test_deployment_dev" {
  depends_on = [
    aws_api_gateway_method.rest_handler_method,
    aws_api_gateway_integration.rest_handler_method-integration
  ]
  rest_api_id = aws_api_gateway_rest_api.rest_handler.id
}

resource "aws_api_gateway_stage" "test" {
  stage_name    = "dev"
  rest_api_id   = aws_api_gateway_rest_api.rest_handler.id
  deployment_id = aws_api_gateway_deployment.test_deployment_dev.id
}

resource "aws_api_gateway_method_settings" "s" {
  rest_api_id = aws_api_gateway_rest_api.rest_handler.id
  stage_name  = aws_api_gateway_stage.test.stage_name
  method_path = "${aws_api_gateway_resource.rest_handler_resource.path_part}/${aws_api_gateway_method.rest_handler_method.http_method}"

  settings {
    metrics_enabled = true
    logging_level   = "INFO"
  }
}

output "dev_url" {
  value = "https://${aws_api_gateway_deployment.test_deployment_dev.rest_api_id}.execute-api.${var.region}.amazonaws.com/${aws_api_gateway_stage.test.stage_name}"
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