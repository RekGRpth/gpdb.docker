#!/bin/sh -eux

docker build \
    --build-arg GP_MAJOR=7 \
    --file gpdb7.Dockerfile \
    --pull \
    --network=host \
    --tag gpdb7 \
    . 2>&1 | tee build7.log
