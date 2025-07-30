#!/bin/sh -eux

docker build \
    --build-arg GP_MAJOR=9 \
    --file gpdb9.Dockerfile \
    --pull \
    --network=host \
    --tag gpdb9 \
    . 2>&1 | tee build9.log
