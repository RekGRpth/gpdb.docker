#!/bin/sh -eux

docker build --progress=plain --tag "ghcr.io/rekgrpth/gpdb.docker:${INPUTS_BRANCH:-ubuntu}" $(env | grep -E '^DOCKER_' | grep -v ' ' | sort -u | sed 's@^@--build-arg @g' | paste -s -d ' ') --file "${INPUTS_DOCKERFILE:-ubuntu.Dockerfile}" . 2>&1 | tee build.log
