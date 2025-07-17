#!/bin/sh -eux

docker build \
    --build-arg GP_MAJOR=7u \
    --file gpdb7u.Dockerfile \
    --pull \
    --network=host \
    --tag gpdb7u \
    . 2>&1 | tee build7u.log
