#!/bin/bash

sudo chmod a+x ./run.sh

docker network rm _mongonet > /dev/null 2>&1
docker network create -d bridge _mongonet

NETWORK_ID=$(docker inspect -f '{{range.IPAM.Config}}{{.Gateway}}{{end}}' _mongonet | sed "s/.$//")

sed -i "23s/^.*$/  bindIp: 127.0.0.1,${NETWORK_ID}2/" $PWD/config/mongod.conf
sed -i "23s/^.*$/  bindIp: 127.0.0.1,${NETWORK_ID}3/" $PWD/config/mongod2.conf
sed -i "23s/^.*$/  bindIp: 127.0.0.1,${NETWORK_ID}4/" $PWD/config/mongod3.conf

