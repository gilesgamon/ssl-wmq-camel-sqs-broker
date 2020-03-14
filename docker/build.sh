#!/bin/bash

docker build . -f Dockerfile_aws_node12 -t node12
docker build . -f Dockerfile_ibm_java -t ibm_java
docker build . -f Dockerfile_camelrouterbuild -t camelrouterbuild