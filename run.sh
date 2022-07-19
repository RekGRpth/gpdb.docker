#!/bin/sh -eux

#docker pull "ghcr.io/rekgrpth/gpdb.docker:${INPUTS_BRANCH:-latest}"
docker network create --attachable --opt com.docker.network.bridge.name=docker docker || echo $?
docker volume create gpdb
docker stop gpdb || echo $?
docker rm gpdb || echo $?
docker run \
    --detach \
    --env ASAN_OPTIONS="detect_odr_violation=0,alloc_dealloc_mismatch=false,halt_on_error=false" \
    --env GROUP_ID="$(id -g)" \
    --env LANG=ru_RU.UTF-8 \
    --env TZ=Asia/Yekaterinburg \
    --env USER_ID="$(id -u)" \
    --hostname gpdb \
    --memory=8g \
    --memory-swap=8g \
    --mount type=bind,source=/etc/certs,destination=/etc/certs,readonly \
    --mount type=volume,source=gpdb,destination=/home \
    --name gpdb \
    --network name=docker,alias=gpdb."$(hostname -d)" \
    --restart always \
    "ghcr.io/rekgrpth/gpdb.docker:${INPUTS_BRANCH:-ubuntu}" /usr/sbin/sshd -De
