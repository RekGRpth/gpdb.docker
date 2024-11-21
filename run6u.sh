#!/bin/sh -eux

docker network create --attachable --ipv6 --subnet 2001:db8::/112 --opt com.docker.network.bridge.name=docker docker || echo $?
docker volume create gpdb
docker stop gpdb6u || echo $?
docker rm gpdb6u || echo $?
mkdir -p /tmpfs/data/6u /tmpfs/data/6u.test
docker run \
    --detach \
    --env GOPATH=/usr/local/go \
    --env GP_MAJOR=6u \
    --env GROUP_ID="$(id -g)" \
    --env LANG=ru_RU.UTF-8 \
    --env PGPORT=6000 \
    --env PORT_BASE=6000 \
    --env TZ=Asia/Yekaterinburg \
    --env USER_ID="$(id -u)" \
    --hostname gpdb6u \
    --init \
    --memory=16g \
    --memory-swap=16g \
    --mount type=bind,source="$(docker volume inspect --format "{{ .Mountpoint }}" gpdb)/.local/6u",destination=/usr/local \
    --mount type=bind,source=/tmpfs/data/6u,destination=/home/gpadmin/.data \
    --mount type=bind,source=/tmpfs/data/6u.test,destination=/home/gpadmin/gpdb_src/src/test \
    --mount type=volume,source=gpdb,destination=/home/gpadmin \
    --name gpdb6u \
    --network name=docker \
    --privileged \
    --restart always \
    --sysctl "kernel.sem=500 1024000 200 4096" \
    gpdb6u sudo /usr/sbin/sshd -De
