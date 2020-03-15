#!/bin/bash

docker build . -f Dockerfile_aws_node12 -t node12
docker build . -f Dockerfile_ibm_java -t ibm_java
docker build . -f Dockerfile_camelrouterbuild -t camelrouterbuild
docker create --name tempCamel camelrouterbuild
mkdir -p ../artefacts
docker cp tempCamel:/tmp/server-chain.jks ../artefacts
docker cp tempCamel:/tmp/broker-1.0-SNAPSHOT.jar ../artefacts
docker rm tempCamel