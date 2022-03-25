#!/bin/bash

docker run -it --rm --name mongo \
	-v ~/mongodb/replica-dbs:/data/db/ \
	-w /data/db \
	mongo:latest bash -c " mongod --port 27018 --dbpath /data/db/db1 --replSet replica > /dev/null 2>&1 & disown \\

mongod --port 27019 --dbpath /data/db/db2 --replSet replica > /dev/null 2>&1 & disown \\

mongod --port 27020 --dbpath /data/db/db3 --replSet replica > /dev/null 2>&1 & sleep 0.5 && bash"

echo "27018 27019 27020"
