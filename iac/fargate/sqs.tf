resource "aws_sqs_queue" "SqsToMqQueue" {
  name                      = var.request_queue_name
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 60
  receive_wait_time_seconds = 10
  depends_on                = [ aws_instance.docker_for_mq ]
}

resource "aws_sqs_queue" "mqToSqsQueue" {
  name                      = var.response_queue_name
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 60
  receive_wait_time_seconds = 10
  depends_on                = [ aws_instance.docker_for_mq ]
}