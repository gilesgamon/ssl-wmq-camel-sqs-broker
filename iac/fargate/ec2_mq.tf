resource "aws_instance" "docker_for_mq" {
  ami                         = "${data.aws_ami.aws_for_mq.id}"
  instance_type               = var.instance_type
  vpc_security_group_ids      = [ aws_security_group.mqtls.id ]
  subnet_id                   = module.camel_vpc.private_subnets[0]
  key_name                    = var.key_pair_name
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.ec2_mq_profile.name
  user_data                   = base64encode(templatefile("${path.module}/templates/ec2_mq.tmpl", { accountId = var.account_id }))
  depends_on                  = [ aws_cloudwatch_log_group.mqtls_host ]

  tags = {
    Name = "MQ TLS"
  }
}

data "aws_ami" "aws_for_mq" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
    filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

resource "aws_cloudwatch_log_group" "mqtls_host" {
  name                  = "/aws/ec2/mqtls_host"
  retention_in_days     = 14
}