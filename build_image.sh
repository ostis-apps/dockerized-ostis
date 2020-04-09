#!/bin/sh

IMAGE="ostis/ostis"
VERSION="scp_stable"

docker build -t ${IMAGE}:${VERSION} .

exit

