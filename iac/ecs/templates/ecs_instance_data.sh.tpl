#!/bin/bash
cat <<EOF > /etc/ecs/ecs.config
ECS_CLUSTER=${ecs_cluster_name}
EOF
