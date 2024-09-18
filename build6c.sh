#!/bin/sh -eux

export GP_MAJOR=6

docker pull "hub.adsw.io/library/gpdb${GP_MAJOR}_regress:latest"
docker build \
    --build-arg GP_MAJOR=$GP_MAJOR \
    --file "gpdb${GP_MAJOR}c.Dockerfile" \
    --pull \
    --tag "gpdb${GP_MAJOR}c" \
    . 2>&1 | tee "build${GP_MAJOR}c.log"
