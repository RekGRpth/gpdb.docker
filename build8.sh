#!/bin/sh -eux

export GP_MAJOR=8
docker build \
    --file "gpdb$GP_MAJOR.Dockerfile" \
    --pull \
    --network=host \
    --tag "gpdb$GP_MAJOR" \
    . 2>&1 | tee "build$GP_MAJOR.log"
