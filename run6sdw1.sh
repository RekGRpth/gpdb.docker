#!/bin/sh -eux

docker network create --attachable --ipv6 --subnet 2001:db8::/112 --opt com.docker.network.bridge.name=docker docker || echo $?
docker volume create gpdb
export GPDB="$(docker volume inspect --format "{{ .Mountpoint }}" gpdb)"
export GP_MAJOR=6
docker stop sdw1 || echo $?
docker rm sdw1 || echo $?
mkdir -p "$GPDB/.ccache/$GP_MAJOR"
mkdir -p "$GPDB/gpAdminLogs/$GP_MAJOR"
docker run \
    --detach \
    --env GROUP_ID="$(id -g)" \
    --env USER_ID="$(id -u)" \
    --hostname sdw1 \
    --init \
    --memory=16g \
    --memory-swap=16g \
    --mount type=bind,source="$GPDB/.ccache/$GP_MAJOR",destination=/home/gpadmin/.ccache \
    --mount type=bind,source="$GPDB/gpAdminLogs/$GP_MAJOR",destination=/home/gpadmin/gpAdminLogs \
    --mount type=bind,source="$GPDB/src/gpdb$GP_MAJOR",destination=/home/gpadmin/gpdb_src \
    --mount type=bind,source="$GPDB/src/gpdb$GP_MAJOR/src/test",destination=/home/gpadmin/gpdb_src/src/test \
    --mount type=bind,source="/tmpfs/data/$GP_MAJOR",destination=/home/gpadmin/.data \
    --mount type=volume,source=gpdb,destination=/home/gpadmin \
    --name sdw1 \
    --network name=docker \
    --privileged \
    --sysctl "kernel.sem=500 1024000 200 4096" \
    --sysctl "net.unix.max_dgram_qlen=4096" \
    "gpdb$GP_MAJOR" sudo /usr/sbin/sshd -De
