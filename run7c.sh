#!/bin/sh -eux

docker network create --attachable --ipv6 --subnet 2001:db8::/112 --opt com.docker.network.bridge.name=docker docker || echo $?
docker volume create gpdb
docker stop gpdb7c || echo $?
docker rm gpdb7c || echo $?
mkdir -p /tmpfs/data/7c /tmpfs/data/7c.test
docker run \
    --detach \
    --env GP_MAJOR=7c \
    --env GROUP_ID="$(id -g)" \
    --env LANG=ru_RU.UTF-8 \
    --env PGPORT=7000 \
    --env TZ=Asia/Yekaterinburg \
    --env USER_ID="$(id -u)" \
    --hostname gpdb7c \
    --init \
    --memory=16g \
    --memory-swap=16g \
    --mount type=bind,source="$(docker volume inspect --format "{{ .Mountpoint }}" gpdb)/.local/7c",destination=/usr/local \
    --mount type=bind,source=/tmpfs/data/7c,destination=/home/gpadmin/.data \
    --mount type=bind,source=/tmpfs/data/7c.test,destination=/home/gpadmin/gpdb_src/src/test \
    --mount type=volume,source=gpdb,destination=/home/gpadmin \
    --name gpdb7c \
    --network name=docker \
    --privileged \
    --restart always \
    --sysctl "kernel.sem=500 1024000 200 4096" \
    gpdb7c sudo /usr/sbin/sshd -De
