#!/bin/sh -eux

export GP_MAJOR=6

docker build \
    --build-arg GP_MAJOR=$GP_MAJOR \
    --file "gpdb${GP_MAJOR}u.Dockerfile" \
    --pull \
    --tag "gpdb${GP_MAJOR}u" \
    . 2>&1 | tee "build${GP_MAJOR}u.log"
