#!/bin/sh -eux

docker build \
    --build-arg GP_MAJOR=5c \
    --file gpdb5c.Dockerfile \
    --pull \
    --tag gpdb5c \
    . 2>&1 | tee build5c.log
