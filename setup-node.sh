#!/bin/sh

docker pull 121180073/dis-node
docker pull fluree/ledger
docker pull openwhisk/standalone:nightly

docker run --rm -p 50007:50007 -e TYPE=master -e HOST=192.168.1.70 -v /var/run/docker.sock:/var/run/docker.sock --name dis-node --privileged dis-node:latest
