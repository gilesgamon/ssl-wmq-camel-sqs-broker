#!/bin/bash
yum update -y
cat <<EOF > /etc/ecs/ecs.config
ECS_CLUSTER=${ecs_cluster_name}
ECS_AWSVPC_BLOCK_IMDS=true
EOF

yum install -y iptables-services
iptables --insert FORWARD 1 --in-interface docker+ --destination 169.254.169.254/32 --jump DROP
iptables-save | sudo tee /etc/sysconfig/iptables
service iptables save