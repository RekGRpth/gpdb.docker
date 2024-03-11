#!/bin/sh -eux

export GP_MAJOR=7

docker network create --attachable --ipv6 --subnet 2001:db8::/112 --opt com.docker.network.bridge.name=docker docker || echo $?
docker volume create gpdb
docker stop "gpdb$GP_MAJOR" || echo $?
docker rm "gpdb$GP_MAJOR" || echo $?
docker run \
    --detach \
    --env GP_MAJOR="$GP_MAJOR" \
    --env GROUP_ID="$(id -g)" \
    --env LANG=ru_RU.UTF-8 \
    --env TZ=Asia/Yekaterinburg \
    --env USER_ID="$(id -u)" \
    --hostname "gpdb$GP_MAJOR" \
    --init \
    --memory=16g \
    --memory-swap=16g \
    --mount type=bind,source="$(docker volume inspect --format "{{ .Mountpoint }}" gpdb)/.local/$GP_MAJOR",destination=/usr/local \
    --mount type=bind,source="/tmpfs/data/$GP_MAJOR",destination="/home/gpadmin/.data/$GP_MAJOR" \
    --mount type=volume,source=gpdb,destination=/home/gpadmin \
    --name "gpdb$GP_MAJOR" \
    --network name=docker \
    --privileged \
    --restart always \
    --sysctl "kernel.sem=500 1024000 200 4096" \
    "gpdb$GP_MAJOR" sudo /usr/sbin/sshd -De
