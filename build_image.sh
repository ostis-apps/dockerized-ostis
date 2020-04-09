#!/bin/sh

IMAGE="ostis"
VERSION="scp_stable"

docker build -t ${IMAGE}:${VERSION} .

exit

