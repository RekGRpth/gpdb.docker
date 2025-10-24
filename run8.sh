#!/bin/sh -eux

docker network create --attachable --ipv6 --subnet 2001:db8::/112 --opt com.docker.network.bridge.name=docker docker || echo $?
docker volume create gpdb
docker stop gpdb8 || echo $?
docker rm gpdb8 || echo $?
mkdir -p /tmpfs/data/8 /tmpfs/data/8.test
mkdir -p "$(docker volume inspect --format "{{ .Mountpoint }}" gpdb)/.ccache/8"
mkdir -p "$(docker volume inspect --format "{{ .Mountpoint }}" gpdb)/gpAdminLogs/8"
docker run \
    --detach \
    --env GP_MAJOR=8 \
    --env GROUP_ID="$(id -g)" \
    --env LANG=ru_RU.UTF-8 \
    --env TZ=Asia/Yekaterinburg \
    --env USER_ID="$(id -u)" \
    --hostname gpdb8 \
    --init \
    --memory=16g \
    --memory-swap=16g \
    --mount type=bind,source="$(docker volume inspect --format "{{ .Mountpoint }}" gpdb)/.ccache/8",destination=/home/gpadmin/.ccache \
    --mount type=bind,source="$(docker volume inspect --format "{{ .Mountpoint }}" gpdb)/gpAdminLogs/8",destination=/home/gpadmin/gpAdminLogs \
    --mount type=bind,source="$(docker volume inspect --format "{{ .Mountpoint }}" gpdb)/src/gpdb8",destination=/home/gpadmin/gpdb_src \
    --mount type=bind,source=/tmpfs/data/8,destination=/home/gpadmin/.data \
    --mount type=bind,source=/tmpfs/data/8.test,destination=/home/gpadmin/gpdb_src/src/test \
    --mount type=volume,source=gpdb,destination=/home/gpadmin \
    --name gpdb8 \
    --network name=docker \
    --privileged \
    --restart always \
    --sysctl "kernel.sem=500 1024000 200 4096" \
    --sysctl "net.unix.max_dgram_qlen=4096" \
    gpdb8 sudo /usr/sbin/sshd -De
