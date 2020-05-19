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