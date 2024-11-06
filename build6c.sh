#!/bin/sh -eux

docker build \
    --build-arg GP_MAJOR=6c \
    --file gpdb6c.Dockerfile \
    --pull \
    --tag gpdb6c \
    . 2>&1 | tee build6c.log
