#!/bin/sh -eux

docker network create --attachable --ipv6 --subnet 2001:db8::/112 --opt com.docker.network.bridge.name=docker docker || echo $?
docker volume create gpdb
export GPDB="$(docker volume inspect --format "{{ .Mountpoint }}" gpdb)"
export GP_MAJOR=9
docker stop "gpdb$GP_MAJOR" || echo $?
docker rm "gpdb$GP_MAJOR" || echo $?
mkdir -p "$GPDB/.ccache/$GP_MAJOR"
mkdir -p "$GPDB/gpAdminLogs/$GP_MAJOR"
docker run \
    --detach \
    --env GROUP_ID="$(id -g)" \
    --env USER_ID="$(id -u)" \
    --hostname "gpdb$GP_MAJOR" \
    --init \
    --memory=16g \
    --memory-swap=16g \
    --mount type=bind,source="$GPDB/.ccache/$GP_MAJOR",destination=/home/gpadmin/.ccache \
    --mount type=bind,source="$GPDB/gpAdminLogs/$GP_MAJOR",destination=/home/gpadmin/gpAdminLogs \
    --mount type=bind,source="$GPDB/src/gpdb$GP_MAJOR",destination=/home/gpadmin/gpdb_src \
    --mount type=bind,source="$GPDB/src/gpdb$GP_MAJOR/src/test",destination=/home/gpadmin/gpdb_src/src/test \
    --mount type=bind,source="/tmpfs/data/$GP_MAJOR",destination=/home/gpadmin/.data \
    --mount type=volume,source=gpdb,destination=/home/gpadmin \
    --name "gpdb$GP_MAJOR" \
    --network name=docker \
    --privileged \
    --restart always \
    --sysctl "kernel.sem=500 1024000 200 4096" \
    --sysctl "net.unix.max_dgram_qlen=4096" \
    "gpdb$GP_MAJOR" sudo /usr/sbin/sshd -De
