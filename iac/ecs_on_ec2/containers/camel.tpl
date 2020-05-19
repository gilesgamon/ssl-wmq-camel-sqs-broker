[
  {
    "name": "${var.name}",
    "image": "${var.image}",
    "cpu": 0,
    "memory": 256,
    "environment": [ "name" : "MQ_HOSTNAME", "value", "mq.lsiarchi.consulting"]
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "${var.region}",
        "awslogs-group": "${var.name}",
        "awslogs-stream-prefix": "complete-ecs"
      }
    }
  }
]