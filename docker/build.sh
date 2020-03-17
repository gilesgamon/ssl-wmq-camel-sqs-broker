#!/bin/bash

docker build . -f Dockerfile_aws_node12 -t node12
docker build . -f Dockerfile_ibm_java -t ibm_java
docker build . -f Dockerfile_camelrouterbuild -t camelrouterbuild
docker create --name tempCamel camelrouterbuild
mkdir -p ../artefacts
docker cp tempCamel:/tmp/server-chain.jks .
docker cp tempCamel:/tmp/broker-1.0-SNAPSHOT.jar .
docker rm tempCamel
# Now use a clean container, to build a runtime (without Maven etc)
docker build . -f Dockerfile_came_router_runtime -t camelrouterruntime
mv ./server-chain.jks ../artefacts
mv ./broker-1.0-SNAPSHOT.jar ../artefacts
# To upload via s3 for user_data, things got complicated - doing via an s3 single upload should be easier (for EC2 / other deployment)
cp -f ibm_java_install_response_file ../artefacts
cp -R ../startup ../artefacts
cp -f safe/ibm-java-x86_64-sdk-8.0-6.6.bin ../artefacts
cd ..
rm -f artefacts.tgz
tar czf artefacts.tgz artefacts
