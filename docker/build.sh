#!/bin/bash

mkdir -p safe
docker build . -f Dockerfile_CertificateAuthority -t certauth
docker create --name tempCA certauth
retval=$?
if [ $retval -ne 0 ]; then
    echo "Return code was not zero but $retval"
    exit 1
fi
docker cp tempCA:/root/ca/intermediate/private/mq_user.lsiarchi.consulting.key.pem safe/client.key
retval=$?
if [ $retval -ne 0 ]; then
    echo "Return code was not zero but $retval"
    exit 1
fi
docker cp tempCA:/root/ca/intermediate/certs/mq_user.lsiarchi.consulting.cert.pem safe/client.pem
docker cp tempCA:/root/ca/intermediate/private/mq.lsiarchi.consulting.key.pem safe/mq_server.key
docker cp tempCA:/root/ca/intermediate/certs/mq.lsiarchi.consulting.cert.pem safe/mq_server.pem
docker cp tempCA:/root/ca/certs/ca.cert.pem safe/ca.pem
docker cp tempCA:/root/ca/intermediate/certs/intermediate.cert.pem safe/intermediate.pem
docker cp tempCA:/root/ca/intermediate/certs/ca-chain.cert.pem safe/ca-chain.pem
docker rm tempCA
retval=$?
if [ $retval -ne 0 ]; then
    echo "Return code was not zero but $retval"
    exit 1
fi

# Create/refresh a working structure for IBM's MQ TLS docker instance to load TLS info
mkdir -p mqm/mykey mqm/trust/0
find mqm -type f -delete
chmod -R a+w mqm
cp -f safe/ca-chain.pem mqm/mykey/ca.crt
retval=$?
if [ $retval -ne 0 ]; then
    echo "Return code was not zero but $retval"
    exit 1
fi
cp -f safe/mq_server.pem mqm/mykey/key.crt
cp -f safe/mq_server.key mqm/mykey/key.key
cp -f safe/client.pem mqm/trust/0/client.pem
chmod -R a+r mqm
find mqm -type d -exec chmod a+x {} \;

# Now we have certs, let's create the jks files
source safe/secrets
cd ..
./parse_params
cd docker

docker build . -f Dockerfile_ibm_mq_tls_latest -t ibm_mq_tls
retval=$?
if [ $retval -ne 0 ]; then
    echo "Return code was not zero but $retval"
    exit 1
fi
# for test/debug
# exit
# docker run --name mqtls --p 1414:1414 --p 9443:9443 --detach ibm_mq_tls
# openssl s_client -showcerts -connect localhost:1414
# user = admin/passw0rd

docker build . -f Dockerfile_aws_node12 -t node12
retval=$?
if [ $retval -ne 0 ]; then
    echo "Return code was not zero but $retval"
    exit 1
fi

if [ ! -f "ibm-java-x86_64-sdk-8.0-6.6.bin" ] ; then
	echo "fetching IBM's Java"
	curl -o ibm-java-x86_64-sdk-8.0-6.6.bin http://public.dhe.ibm.com/ibmdl/export/pub/systems/cloud/runtimes/java/8.0.6.6/linux/x86_64/ibm-java-x86_64-sdk-8.0-6.6.bin
fi

echo "Building ibm_java docker image"
docker build . -f Dockerfile_ibm_java -t ibm_java
retval=$?
if [ $retval -ne 0 ]; then
    echo "Return code was not zero but $retval"
    exit 1
fi

echo "Building camel_router_build docker image"
docker build ~/ssl-wmq-camel-sqs-broker -f Dockerfile_camel_router_build -t camel_router_build
retval=$?
if [ $retval -ne 0 ]; then
    echo "Return code was not zero but $retval"
    exit 1
fi

docker create --name tempCamel camel_router_build
retval=$?
if [ $retval -ne 0 ]; then
    echo "Return code was not zero but $retval"
    exit 1
fi
# docker run --name tempCamel camel_router_build
mkdir -p ../artefacts
docker cp tempCamel:/tmp/server-chain.jks .
retval=$?
if [ $retval -ne 0 ]; then
    echo "Return code was not zero but $retval"
    exit 1
fi
docker cp tempCamel:/tmp/client.jks .
docker cp tempCamel:/tmp/broker-1.0-SNAPSHOT.jar .
docker rm tempCamel

# Now use a clean container, to build a runtime (without Maven etc)
echo "Building camel_router_runtime docker image"
docker build . -f Dockerfile_camel_router_runtime --squash -t camel_router_runtime
retval=$?
if [ $retval -ne 0 ]; then
    echo "Return code was not zero but $retval"
    exit 1
fi

cd ../iac/ecr
terraform init
retval=$?
if [ $retval -ne 0 ]; then
    echo "Return code was not zero but $retval"
    exit 1
fi
terraform apply -auto-approve
retval=$?
if [ $retval -ne 0 ]; then
    echo "Return code was not zero but $retval"
    exit 1
fi
`aws ecr get-login --no-include-email --region eu-west-1`
retval=$?
if [ $retval -ne 0 ]; then
    echo "Return code was not zero but $retval"
    exit 1
fi
docker tag camel_router_runtime:latest 272154369820.dkr.ecr.eu-west-1.amazonaws.com/camel-broker:latest
docker tag ibm_mq_tls:latest 272154369820.dkr.ecr.eu-west-1.amazonaws.com/ibm_mq_tls:latest
echo "Uploading Camel docker image"
docker push 272154369820.dkr.ecr.eu-west-1.amazonaws.com/camel-broker:latest
retval=$?
if [ $retval -ne 0 ]; then
    echo "Return code was not zero but $retval"
    exit 1
fi
echo "Uploading MQ docker image"
docker push 272154369820.dkr.ecr.eu-west-1.amazonaws.com/ibm_mq_tls:latest
retval=$?
if [ $retval -ne 0 ]; then
    echo "Return code was not zero but $retval"
    exit 1
fi

cd ../fargate
terraform init
retval=$?
if [ $retval -ne 0 ]; then
    echo "Return code was not zero but $retval"
    exit 1
fi
terraform apply -auto-approve
retval=$?
if [ $retval -ne 0 ]; then
    echo "Return code was not zero but $retval"
    exit 1
fi
