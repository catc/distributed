#! /usr/bin/env bash

CONTAINER_NAME="cat-nginx"  # docker container name
CONTAINER_PORT="9030"       # nginx port

NGINX_CONF="./ws.conf"      # name of nginx conf to copy to container

# ************
# running:
# - change any variables above
# - add/remove any upstream servers from nginx conf file
# - start instance via:
#       $ ./nginx start
#       $ ./nginx copy
# 
# other commands:
#       $ ./nginx logs        # logs
#       $ ./nginx exec        # connect to container
#       $ ./nginx rm        # stop and remove
# ************

function start {
	echo "*** starting nginx instance"

    docker run \
        --name ${CONTAINER_NAME} \
        -p ${CONTAINER_PORT}:${CONTAINER_PORT} \
        -d \
        -p 80:80 \
        nginx:1.15.3-alpine
}

function copy {
	echo "*** copying conf"
    docker cp ${NGINX_CONF} ${CONTAINER_NAME}:/etc/nginx/conf.d

    echo "*** restarting instance"
    docker restart ${CONTAINER_NAME}
}

function rm {
	echo "*** stopping and removing ${CONTAINER_NAME}"
    docker stop ${CONTAINER_NAME}
    docker rm ${CONTAINER_NAME}
}


if [ $# -eq 0 ]; then
	echo "must specify valid option"
elif [ "$1" == "copy" ]; then
	copy
elif [ "$1" == "exec" ]; then
    docker exec -it ${CONTAINER_NAME} /bin/sh
elif [ "$1" == "rm" ]; then
	rm
elif [ "$1" == "logs" ]; then
	docker logs -f ${CONTAINER_NAME}
elif [ "$1" == "start" ]; then
	start
else
	exit_with_err
fi