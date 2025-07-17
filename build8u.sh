#!/bin/sh -eux

docker build \
    --build-arg GP_MAJOR=8u \
    --file gpdb8u.Dockerfile \
    --pull \
    --network=host \
    --tag gpdb8u \
    . 2>&1 | tee build8u.log
