#!/bin/sh -eux

docker pull hub.adsw.io/library/docker:20.10.17-x64
docker network create --attachable --ipv6 --subnet 2001:db8::/112 --opt com.docker.network.bridge.name=docker docker || echo $?
docker volume create gpdb
docker stop ubuntu || echo $?
docker rm ubuntu || echo $?
docker run \
    --detach \
    --hostname ubuntu \
    --init \
    --mount type=volume,source=gpdb,destination=/home/gpadmin \
    --name ubuntu \
    --network name=docker \
    --privileged \
    --restart always \
    hub.adsw.io/library/docker:20.10.17-x64 sleep infinity
