#!/bin/sh

IMAGE="clion/remote-cpp-env"
VERSION="0.5"

docker build -t ${IMAGE}:${VERSION} -f ./clion_debug/Dockerfile.clion-cpp-env .

exit

