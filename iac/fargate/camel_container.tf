module "camel-container" {
	source 			  = "git::https://github.com/cloudposse/terraform-aws-ecs-container-definition.git"
	container_name 	  = local.name
	container_image   = "${var.account_id}.dkr.ecr.eu-west-1.amazonaws.com/camel-broker:latest"
	environment 	  = [
							{
								name = "MQ_HOSTNAME"
								value = var.mq_url
							}
						]
	log_configuration = {
		logDriver = "awslogs",
		options = { "awslogs-region" = "${var.region}", "awslogs-group" = "/aws/ecs/tasks/ecs_camel", "awslogs-stream-prefix" = "complete-ecs" },
		secretOptions = null
	}

	port_mappings = [
		{
			containerPort	= 1414
			hostPort		= 1414
			protocol		= "tcp"
		},
		{
			containerPort	= 9443
			hostPort		= 9443
			protocol		= "tcp"
		}
	]
}

output "json" {
	description = "MQ Container"
	value		= module.camel-container.json
}