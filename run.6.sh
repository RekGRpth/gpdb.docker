#!/bin/sh -eux

#docker pull "ghcr.io/rekgrpth/gpdb.docker:${INPUTS_BRANCH:-latest}"
docker network create --attachable --opt com.docker.network.bridge.name=docker docker || echo $?
docker volume create gpdb
docker stop gpdb6 || echo $?
docker rm gpdb6 || echo $?
docker run \
    --cap-add=SYS_PTRACE \
    --detach \
    --env GP_MAJOR=6 \
    --env GROUP_ID="$(id -g)" \
    --env LANG=ru_RU.UTF-8 \
    --env TZ=Asia/Yekaterinburg \
    --env USER_ID="$(id -u)" \
    --hostname gpdb6 \
    --memory=32g \
    --memory-swap=32g \
    --mount type=bind,source=/etc/certs,destination=/etc/certs,readonly \
    --mount type=bind,source=/sys,destination=/sys,readonly \
    --mount type=volume,source=gpdb,destination=/home \
    --mount type=bind,source="$(docker volume inspect --format "{{ .Mountpoint }}" gpdb)/.local/6",destination=/usr/local \
    --mount type=bind,source=/tmpfs/data/6,destination=/home/.data/6 \
    --name gpdb6 \
    --network name=docker,alias=gpdb6."$(hostname -d)" \
    --privileged \
    --restart always \
    "ghcr.io/rekgrpth/gpdb.docker:${INPUTS_BRANCH:-centos}" sudo /usr/sbin/sshd -De
