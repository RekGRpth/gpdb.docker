#!/bin/bash -eux

export GP_MAJOR=6

exec 2>&1 &> >(tee "build$GP_MAJOR.log")

docker build \
    --file "gpdb$GP_MAJOR.Dockerfile" \
    --pull \
    --network=host \
    --tag "gpdb$GP_MAJOR" \
    .
