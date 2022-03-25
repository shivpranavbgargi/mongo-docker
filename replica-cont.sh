#!/bin/bash

mkdir db-repl db-repl2 db-repl3

cp mongod.conf ./db-repl && \
cp mongod2.conf ./db-repl2 && \
cp mongod3.conf ./db-repl3

docker run -d --name mongo-repl \
	-v ./db-repl:/data/db/ \
	-w /data/db \
	-p 27017:27017 \
	mongo:latest bash -c "mongod --config /data/db/mongod.conf" 

docker run -d --name mongo-repl2 \
	-v ./db-repl2:/data/db/ \
	-w /data/db \
	-p 27018:27017 \
	mongo:latest bash -c "mongod --config /data/db/mongod2.conf"

docker run -d --name mongo-repl3 \
	-v ./db-repl3:/data/db/ \
	-w /data/db \
	-p 27019:27017 \
	mongo:latest bash -c "mongod --config /data/db/mongod3.conf" 
