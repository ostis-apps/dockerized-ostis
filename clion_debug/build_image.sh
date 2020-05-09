#!/bin/sh

IMAGE="ostis/clion-remote-cpp-env"
VERSION="0.6.0"

docker build -t ${IMAGE}:${VERSION} -f ./clion_debug/Dockerfile.clion-cpp-env .

exit

