#!/bin/sh -eux

docker build \
    --build-arg GP_MAJOR=9u \
    --file qpdb9u.Dockerfile \
    --pull \
    --tag qpdb9u \
    . 2>&1 | tee build9u.log
