#!/bin/bash

# Checking if docker engine is installed
if ! cmd_loc="$(type -p docker)" || [[ -z $cmd_loc ]]; then
  echo -e "Install docker first.\nREF: https://docs.docker.com/engine/install"
  exit 1
fi

# docker exec
function execute(){
echo "" 
docker exec -it mongo-repl bash 
}

# Network setup
function setup(){

docker network rm _mongonet > /dev/null 2>&1
docker network create -d bridge _mongonet

network_id=$(docker inspect -f '{{range.IPAM.Config}}{{.Gateway}}{{end}}' _mongonet | sed "s/.$//")

sed -i "23s/^.*$/  bindIp: 127.0.0.1,${network_id}2/" $PWD/config/mongod.conf
sed -i "23s/^.*$/  bindIp: 127.0.0.1,${network_id}3/" $PWD/config/mongod2.conf
sed -i "23s/^.*$/  bindIp: 127.0.0.1,${network_id}4/" $PWD/config/mongod3.conf
}

# 1DB - No replication - Single container
function normal(){

mkdir db > /dev/null 2>&1

docker run -it --rm --name mongo \
	-v $(pwd)/db:/data/db/ \
	-w /data/db \
	mongo:latest bash -c "mongod > /dev/null 2>&1 & sleep .5 && bash"
}

# 3DBs - Replication - Single container
function replication-single(){

mkdir -p db-replica/db{1,2,3} > /dev/null 2>&1

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

# 3DBs - Replication - Multiple containers(3)
function replication-multi(){

mkdir -p db-repl/db{1,2,3} > /dev/null 2>&1

cp ./config/mongod.conf ./db-repl/db1
cp ./config/mongod2.conf ./db-repl/db2
cp ./config/mongod3.conf ./db-repl/db3

docker run -d --network _mongonet --name mongo-repl \
	-v $(pwd)/db-repl/db1:/data/db/ \
	-w /data/db \
	-p 27017:27017 \
	mongo:latest bash -c "mongod --config /data/db/mongod.conf" > /dev/null 2>&1 
  
docker run -d --network _mongonet --name mongo-repl2 \
	-v $(pwd)/db-repl/db2:/data/db/ \
	-w /data/db \
	-p 27018:27017 \
	mongo:latest bash -c "mongod --config /data/db/mongod2.conf" > /dev/null 2>&1

docker run -d --network _mongonet --name mongo-repl3 \
	-v $(pwd)/db-repl/db3:/data/db/ \
	-w /data/db \
	-p 27019:27017 \
	mongo:latest bash -c "mongod --config /data/db/mongod3.conf" > /dev/null 2>&1
echo ""
echo -e "\e[1;32mDocker containers started!\e[0m"
execute
}

# main function
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
		if [ "$(docker ps -q -f name=mongo-repl)" != "" > /dev/null 2>&1 ]; then
			echo ""
			echo "mongo-repl containers are already running."
			execute
			exit 0
    	fi
		if [ "$(docker network ls -q -f name=_mongonet)" == "" > /dev/null 2>&1 ]; then
			setup
		fi
    	replication-multi
		;;
    *)	
    	echo ""
        echo -e "\e[1;31mError:\e[0m Select 1,2 or 3"
        main
esac
}

main
