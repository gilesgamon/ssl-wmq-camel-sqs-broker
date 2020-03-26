#!/bin/bash

docker build . -f Dockerfile_aws_node12 -t node12
docker build . -f Dockerfile_ibm_java -t ibm_java
docker build ~/ssl-wmq-camel-sqs-broker -f Dockerfile_camel_router_build -t camel_router_build
docker create --name tempCamel camel_router_build
mkdir -p ../artefacts
docker cp tempCamel:/tmp/server-chain.jks .
docker cp tempCamel:/tmp/broker-1.0-SNAPSHOT.jar .
docker rm tempCamel
# Now use a clean container, to build a runtime (without Maven etc)
docker build . -f Dockerfile_camel_router_runtime -t camel_router_runtime

cd ../iac/ecr
terraform init
terraform apply
`aws ecr get-login --no-include-email --region eu-west-1`
docker tag camel_router_runtime:latest 272154369820.dkr.ecr.eu-west-1.amazonaws.com/camel-broker:latest
docker push 272154369820.dkr.ecr.eu-west-1.amazonaws.com/camel-broker:latest

cd ../ecs
terraform init
terraform apply