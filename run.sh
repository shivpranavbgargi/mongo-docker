#!/bin/bash

function normal(){

mkdir db

docker run -it --rm --name mongo \
	-v $(pwd)/db:/data/db/ \
	-w /data/db \
	mongo:latest bash -c "mongod > /dev/null 2>&1 & sleep .5 && bash"
}

function replication-single(){

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
}

function replication-multi(){

mkdir -p db-repl/db{1,2,3}

cp ./config/mongod.conf ./db-repl/db1
cp ./config/mongod2.conf ./db-repl/db2
cp ./config/mongod3.conf ./db-repl/db3

docker run -d --network _mongonet --name mongo-repl \
	-v $(pwd)/db-repl/db1:/data/db/ \
	-w /data/db \
	-p 27017:27017 \
	mongo:latest bash -c "mongod --config /data/db/mongod.conf" 

docker run -d --network _mongonet --name mongo-repl2 \
	-v $(pwd)/db-repl/db2:/data/db/ \
	-w /data/db \
	-p 27018:27017 \
	mongo:latest bash -c "mongod --config /data/db/mongod2.conf"

docker run -d --network _mongonet --name mongo-repl3 \
	-v $(pwd)/db-repl/db3:/data/db/ \
	-w /data/db \
	-p 27019:27017 \
	mongo:latest bash -c "mongod --config /data/db/mongod3.conf" 
}

function main() {
echo ""
echo -e "\e[1;32m	--Menu-- \e[0m"
cat << EOF
1. normal
2. replication-single
3. replication-multi

EOF

read -p "Select 1,2 or 3: " opt
case $opt in
    1)
        normal
        ;;
    2)
        replication-single
        ;;
    3)
    	replication-multi
    	;;
    *)	
    	echo ""
        echo -e "\e[1;31mError:\e[0m Select 1,2 or 3"
        main
esac
}

main
