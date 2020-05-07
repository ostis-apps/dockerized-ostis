#!/bin/sh

IMAGE="ostis/ostis"
VERSION="0.5.0"

docker build -t ${IMAGE}:${VERSION} -f Dockerfile .

exit

