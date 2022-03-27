#!/bin/bash

docker network create -d bridge mongonet

NETWORK_ID = $(docker inspect -f '{{range.IPAM.Config}}{{.Gateway}}{{end}}' mongonet | sed "s/$//")
echo ${NETWORK_ID}

