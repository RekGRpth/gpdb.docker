#!/bin/sh -eux

docker build \
    --build-arg GP_MAJOR=7c \
    --file gpdb7c.Dockerfile \
    --pull \
    --tag gpdb7c \
    . 2>&1 | tee build7c.log
