resource "aws_launch_configuration" "docker_instance" {
    name_prefix                 = "ecs-launch-configuration-"
    image_id                    = data.aws_ami.aws_optimized_ecs.id
    instance_type               = var.instance_type
    iam_instance_profile        = module.ec2-profile.iam_instance_profile_id

    root_block_device {
      volume_type = "standard"
      volume_size = 50
      delete_on_termination = true
    }

    lifecycle {
      create_before_destroy = true
    }

    security_groups             = [ aws_security_group.ecs_tasks_ssh.id, aws_security_group.ecs_tasks.id]
    associate_public_ip_address = "true"
    key_name                    = var.key_pair_name
    user_data                   = data.template_file.ecs_instance_data.rendered

}

data "aws_ami" "aws_optimized_ecs" {
  owners      = ["591542846629"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami*amazon-ecs-optimized"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

data "template_file" "ecs_instance_data" {
  template = "${file("${path.root}/templates/ecs_instance_data.sh.tpl")}"

  vars = {
    ecs_cluster_name = var.ecs_cluster_name
  }
}
