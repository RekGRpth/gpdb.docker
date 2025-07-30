#!/bin/sh -eux

docker build \
    --build-arg GP_MAJOR=8 \
    --file gpdb8.Dockerfile \
    --pull \
    --network=host \
    --tag gpdb8 \
    . 2>&1 | tee build8.log
