#!/bin/sh -eux

docker build \
    --build-arg GP_MAJOR=6 \
    --file gpdb6.Dockerfile \
    --pull \
    --network=host \
    --tag gpdb6 \
    . 2>&1 | tee build6.log
