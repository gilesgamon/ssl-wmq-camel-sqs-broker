module "camel-broker-asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 3.0"

  name = var.ecs_cluster_name

  # Launch configuration
  launch_configuration = aws_launch_configuration.docker_instance.name
  create_lc = false

  image_id             = data.aws_ami.amazon_linux_ecs.id
  instance_type        = "t2.micro"
  security_groups      = data.aws_security_groups.gifted_sgs.ids

  # Auto scaling group
  asg_name                  = var.ecs_cluster_name
  vpc_zone_identifier       = data.aws_subnet_ids.gifted_vpc.ids

  health_check_type         = "EC2"
  min_size                  = var.min_instance_size
  max_size                  = var.max_instance_size
  desired_capacity          = var.desired_capacity
  wait_for_capacity_timeout = 0

  tags = [
    {
      key                 = "Environment"
      value               = local.environment
      propagate_at_launch = true
    },
    {
      key                 = "Cluster"
      value               = local.name
      propagate_at_launch = true
    },
  ]
}