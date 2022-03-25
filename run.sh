#~/bin/bash
docker run -it --rm --name mongo \
	-v ~/mongodb/db:/data/db/ \
	-w /data/db \
	mongo:latest bash -c "mongod > /dev/null 2>&1 & sleep .5 && bash"
