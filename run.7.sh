#!/bin/sh -eux

#docker pull "ghcr.io/rekgrpth/gpdb.docker:${INPUTS_BRANCH:-latest}"
docker network create --attachable --ipv6 --subnet 2001:db8::/112 --opt com.docker.network.bridge.name=docker docker || echo $?
docker volume create gpdb
docker stop gpdb7 || echo $?
docker rm gpdb7 || echo $?
docker run \
    --detach \
    --env GP_MAJOR=7 \
    --env GROUP_ID="$(id -g)" \
    --env LANG=ru_RU.UTF-8 \
    --env TZ=Asia/Yekaterinburg \
    --env USER_ID="$(id -u)" \
    --hostname gpdb7 \
    --init \
    --memory=16g \
    --memory-swap=16g \
    --mount type=bind,source=/etc/certs,destination=/etc/certs,readonly \
    --mount type=volume,source=gpdb,destination=/home \
    --mount type=bind,source="$(docker volume inspect --format "{{ .Mountpoint }}" gpdb)/.local/7",destination=/usr/local \
    --mount type=bind,source=/tmpfs/data/7,destination=/home/.data/7 \
    --name gpdb7 \
    --network name=docker,alias=gpdb7."$(hostname -d)" \
    --privileged \
    --restart always \
    --sysctl 'kernel.sem=500 1024000 200 4096' \
    "ghcr.io/rekgrpth/gpdb.docker:${INPUTS_BRANCH:-centos}" sudo /usr/sbin/sshd -De
#    --cap-add=SYS_PTRACE \
#    --mount type=bind,source=/sys,destination=/sys \
