[
  {
    "name": "${var.name}",
    "image": "${var.image}",
    "cpu": 0,
    "memory": 256,
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