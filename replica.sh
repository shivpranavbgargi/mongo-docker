#!/bin/bash
mkdir -p db-replica/db{1,2,3}

cat << EOF 
Ports used: 27018, 27019, 27020

EOF

docker run -it --rm --name mongo-replica \
	-v $(pwd)/db-replica:/data/db/ \
	-w /data/db \
	mongo:latest bash -c "mongod --port 27018 --dbpath /data/db/db1 --replSet replica > /dev/null 2>&1 & disown \\

mongod --port 27019 --dbpath /data/db/db2 --replSet replica > /dev/null 2>&1 & disown \\

mongod --port 27020 --dbpath /data/db/db3 --replSet replica > /dev/null 2>&1 & sleep 0.5 && bash"

