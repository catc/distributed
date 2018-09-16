#! /usr/bin/env bash

CONTAINER_NAME="cat-nats"  # docker container name

function start {
	echo "*** starting nats server"

    docker run \
        --name ${CONTAINER_NAME} \
        -p 4222:4222 \
        -p 8222:8222 \
        -p 6222:6222 \
        -d \
        nats:1.3.0
}

function rm {
	echo "*** stopping and removing ${CONTAINER_NAME}"
    docker stop ${CONTAINER_NAME}
    docker rm ${CONTAINER_NAME}
}

if [ $# -eq 0 ]; then
	echo "must specify valid option"
elif [ "$1" == "start" ]; then
    start
elif [ "$1" == "rm" ]; then
	rm
else
	exit_with_err
fi