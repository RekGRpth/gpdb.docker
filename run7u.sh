#!/bin/sh -eux

docker network create --attachable --ipv6 --subnet 2001:db8::/112 --opt com.docker.network.bridge.name=docker docker || echo $?
docker volume create gpdb
docker stop gpdb7u || echo $?
docker rm gpdb7u || echo $?
mkdir -p /tmpfs/data/7u /tmpfs/data/7u.test
docker run \
    --detach \
    --env GP_MAJOR=7u \
    --env GROUP_ID="$(id -g)" \
    --env LANG=ru_RU.UTF-8 \
    --env PGPORT=7000 \
    --env PORT_BASE=7000 \
    --env TZ=Asia/Yekaterinburg \
    --env USER_ID="$(id -u)" \
    --hostname gpdb7u \
    --init \
    --memory=16g \
    --memory-swap=16g \
    --mount type=bind,source="$(docker volume inspect --format "{{ .Mountpoint }}" gpdb)/.local/7u",destination=/usr/local \
    --mount type=bind,source=/tmpfs/data/7u,destination=/home/gpadmin/.data \
    --mount type=bind,source=/tmpfs/data/7u.test,destination=/home/gpadmin/gpdb_src/src/test \
    --mount type=volume,source=gpdb,destination=/home/gpadmin \
    --name gpdb7u \
    --network name=docker \
    --privileged \
    --restart always \
    --sysctl "kernel.sem=500 1024000 200 4096" \
    gpdb7u sudo /usr/sbin/sshd -De
