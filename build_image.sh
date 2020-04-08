#!/bin/sh

IMAGE="ostis/ostis"
VERSION="0.6.0"

docker build -t ${IMAGE}:${VERSION} .

exit

