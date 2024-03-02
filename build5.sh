#!/bin/sh -eux

export GP_MAJOR=5

docker build --pull --tag "gpdb${GP_MAJOR}" --file "gpdb${GP_MAJOR}.Dockerfile" . 2>&1 | tee "build${GP_MAJOR}.log"
