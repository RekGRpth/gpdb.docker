#!/bin/sh -eux

docker network create --attachable --ipv6 --subnet 2001:db8::/112 --opt com.docker.network.bridge.name=docker docker || echo $?
docker volume create gpdb
docker stop gpdb5c || echo $?
docker rm gpdb5c || echo $?
mkdir -p /tmpfs/data/5c /tmpfs/data/5c.test
docker run \
    --detach \
    --env GOPATH=/usr/local/go \
    --env GP_MAJOR=5c \
    --env GROUP_ID="$(id -g)" \
    --env LANG=ru_RU.UTF-8 \
    --env PGPORT=5000 \
    --env PORT_BASE=5000 \
    --env TZ=Asia/Yekaterinburg \
    --env USER_ID="$(id -u)" \
    --hostname gpdb5c \
    --init \
    --memory=16g \
    --memory-swap=16g \
    --mount type=bind,source="$(docker volume inspect --format "{{ .Mountpoint }}" gpdb)/.local/5c",destination=/usr/local \
    --mount type=bind,source=/tmpfs/data/5c,destination=/home/gpadmin/.data \
    --mount type=bind,source=/tmpfs/data/5c.test,destination=/home/gpadmin/gpdb_src/src/test \
    --mount type=volume,source=gpdb,destination=/home/gpadmin \
    --name gpdb5c \
    --network name=docker \
    --privileged \
    --restart always \
    --sysctl "kernel.sem=500 1024000 200 4096" \
    --sysctl "net.unix.max_dgram_qlen=4096" \
    gpdb5c sudo /usr/sbin/sshd -De
