# ------ DNS Alias to point at MQ Server -----
resource aws_route53_record "mq" {
  zone_id = var.mq_zone_id
  name    = "mq"
  type    = "A"
  ttl     = 60

  records = [ aws_instance.docker_for_mq.private_ip ]
}
