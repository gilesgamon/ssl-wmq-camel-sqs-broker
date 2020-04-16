#!/bin/bash

mkdir -p safe
docker build . -f Dockerfile_CertificateAuthority -t certauth
docker create --name tempCA certauth
docker cp tempCA:/root/ca/intermediate/private/mq_user.lisarchi.consulting.key.pem safe/client.key
docker cp tempCA:/root/ca/intermediate/certs/mq_user.lisarchi.consulting.cert.pem safe/client.pem
docker cp tempCA:/root/ca/intermediate/private/mqtls.lisarchi.consulting.key.pem safe/mq_server.key
docker cp tempCA:/root/ca/intermediate/certs/mqtls.lisarchi.consulting.cert.pem safe/mq_server.pem
docker cp tempCA:/root/ca/certs/ca.cert.pem safe/ca.pem
docker cp tempCA:/root/ca/intermediate/certs/intermediate.cert.pem safe/intermediate.pem
docker cp tempCA:/root/ca/intermediate/certs/ca-chain.cert.pem safe/ca-chain.pem
docker rm tempCA

# Create a working structure for IBM's MQ TLS docker instance to load TLS info
mkdir -p mqm/mykey mqm/trust/0
cp safe/ca.pem mqm/mykey/ca.crt
cp safe/mq_server.pem mqm/mykey/key.crt
cp safe/mq_server.key mqm/mykey/key.key
cp safe/client.pem mqm/trust/0/client.pem
chmod -R a+r mqm
find mqm -type d -exec chmod a+x {} \;

docker build . -f Dockerfile_ibm_mq_tls -t ibm_mq_tls
#docker run --name mqtls --publish 1414:1414 --publish 9443:9443 --detach ibm_mq_tls
# user = admin/passw0rd

docker build . -f Dockerfile_aws_node12 -t node12
docker build . -f Dockerfile_ibm_java -t ibm_java
docker build ~/ssl-wmq-camel-sqs-broker -f Dockerfile_camel_router_build -t camel_router_build
docker create --name tempCamel camel_router_build
# docker run --name tempCamel camel_router_build
mkdir -p ../artefacts
docker cp tempCamel:/tmp/server-chain.jks .
docker cp tempCamel:/tmp/client.jks .
docker cp tempCamel:/tmp/broker-1.0-SNAPSHOT.jar .
docker rm tempCamel
# Now use a clean container, to build a runtime (without Maven etc)
docker build . -f Dockerfile_camel_router_runtime -t camel_router_runtime

cd ../iac/ecr
terraform init
terraform apply
`aws ecr get-login --no-include-email --region eu-west-1`
docker tag camel_router_runtime:latest 272154369820.dkr.ecr.eu-west-1.amazonaws.com/camel-broker:latest
docker tag ibm_mq_tls:latest 272154369820.dkr.ecr.eu-west-1.amazonaws.com/ibm_mq_tls:latest
docker push 272154369820.dkr.ecr.eu-west-1.amazonaws.com/camel-broker:latest
docker push 272154369820.dkr.ecr.eu-west-1.amazonaws.com/ibm_mq_tls:latest

cd ../main
terraform init
terraform apply