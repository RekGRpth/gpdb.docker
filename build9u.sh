#!/bin/sh -eux

docker build \
    --build-arg GP_MAJOR=9u \
    --file gpdb9u.Dockerfile \
    --pull \
    --network=host \
    --tag gpdb9u \
    . 2>&1 | tee build9u.log
