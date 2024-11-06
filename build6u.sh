#!/bin/sh -eux

docker build \
    --build-arg GP_MAJOR=6u \
    --file gpdb6u.Dockerfile \
    --pull \
    --tag gpdb6u \
    . 2>&1 | tee build6u.log
