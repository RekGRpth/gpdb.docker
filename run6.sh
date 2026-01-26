#!/bin/bash -eux

export GP_MAJOR=6
docker network create --attachable --ipv6 --subnet "2001:db8:$GP_MAJOR:1::/112" --opt "com.docker.network.bridge.name=gpdb$GP_MAJOR" "gpdb$GP_MAJOR" || echo $?
docker volume create gpdb
export GPDB="$(docker volume inspect --format "{{ .Mountpoint }}" gpdb)"
mkdir -p "$GPDB/.ccache/$GP_MAJOR"
rm -rf "$GPDB/.local/$GP_MAJOR"
mkdir -p "$GPDB/.local/$GP_MAJOR"
mkdir -p "$GPDB/gpAdminLogs/$GP_MAJOR"
for HOST in cdw sdw1 sdw2 sdw3 sdw4 sdw5 sdw6; do
    docker stop "gpdb$GP_MAJOR.$HOST" || echo $?
    docker rm "gpdb$GP_MAJOR.$HOST" || echo $?
    docker run \
        --detach \
        --env GROUP_ID="$(id -g)" \
        --env USER_ID="$(id -u)" \
        --hostname "$HOST" \
        --init \
        --memory=16g \
        --memory-swap=16g \
        --mount type=bind,source="$GPDB/.ccache/$GP_MAJOR",destination=/home/gpadmin/.ccache \
        --mount type=bind,source="$GPDB/gpAdminLogs/$GP_MAJOR",destination=/home/gpadmin/gpAdminLogs \
        --mount type=bind,source="$GPDB/.local/$GP_MAJOR",destination=/usr/local \
        --mount type=bind,source="$GPDB/src/gpdb$GP_MAJOR",destination=/home/gpadmin/gpdb_src \
        --mount type=bind,source="$GPDB/src/gpdb$GP_MAJOR/src/test",destination=/home/gpadmin/gpdb_src/src/test \
        --mount type=bind,source="/tmpfs/data/$GP_MAJOR",destination=/home/gpadmin/.data \
        --mount type=volume,source=gpdb,destination=/home/gpadmin \
        --name "gpdb$GP_MAJOR.$HOST" \
        --network "name=gpdb$GP_MAJOR" \
        --privileged \
        --restart always \
        --sysctl "kernel.sem=500 1024000 200 4096" \
        --sysctl "net.unix.max_dgram_qlen=4096" \
        --ulimit nofile=65535 \
        "gpdb$GP_MAJOR" sudo /usr/sbin/sshd -De
done
