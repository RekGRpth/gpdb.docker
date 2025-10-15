#!/bin/sh -eux

docker network create --attachable --ipv6 --subnet 2001:db8::/112 --opt com.docker.network.bridge.name=docker docker || echo $?
docker volume create gpdb
docker stop gpdb9 || echo $?
docker rm gpdb9 || echo $?
mkdir -p /tmpfs/data/9 /tmpfs/data/9.test
docker run \
    --detach \
    --env GP_MAJOR=9 \
    --env GROUP_ID="$(id -g)" \
    --env LANG=ru_RU.UTF-8 \
    --env PGPORT=9000 \
    --env PORT_BASE=9000 \
    --env TZ=Asia/Yekaterinburg \
    --env USER_ID="$(id -u)" \
    --hostname gpdb9 \
    --init \
    --memory=16g \
    --memory-swap=16g \
    --mount type=bind,source="$(docker volume inspect --format "{{ .Mountpoint }}" gpdb)/src/gpdb9",destination=/home/gpadmin/gpdb_src \
    --mount type=bind,source=/tmpfs/data/9,destination=/home/gpadmin/.data \
    --mount type=bind,source=/tmpfs/data/9.test,destination=/home/gpadmin/gpdb_src/src/test \
    --mount type=volume,source=gpdb,destination=/home/gpadmin \
    --name gpdb9 \
    --network name=docker \
    --privileged \
    --restart always \
    --sysctl "kernel.sem=500 1024000 200 4096" \
    --sysctl "net.unix.max_dgram_qlen=4096" \
    gpdb9 sudo /usr/sbin/sshd -De
