#!/bin/sh -eux

export GP_MAJOR=7

docker build --tag "gpdb${GP_MAJOR}" --file "gpdb${GP_MAJOR}.Dockerfile" . 2>&1 | tee "build${GP_MAJOR}.log"
