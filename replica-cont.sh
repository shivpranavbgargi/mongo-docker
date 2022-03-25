#!/bin/bash

docker run -d --name mongo-repl \
	-v ~/mongodb/replica-dbs-containers:/data/db/ \
	-w /data/db \
	-p 27017:27017 \
	mongo:latest bash -c "mongod --config /data/db/mongod.conf" 

docker run -d --name mongo-repl2 \
	-v ~/mongodb/replica-dbs-containers:/data/db/ \
	-w /data/db \
	-p 27018:27017 \
	mongo:latest bash -c "mongod --config /data/db/mongod2.conf"

docker run -d --name mongo-repl3 \
	-v ~/mongodb/replica-dbs-containers:/data/db/ \
	-w /data/db \
	-p 27019:27017 \
	mongo:latest bash -c "mongod --config /data/db/mongod3.conf" 
