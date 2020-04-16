FROM ubuntu:18.04

#
# Creating image
#
# Add sudo user
RUN apt-get update && apt-get install -y sudo

USER root

# Getting dependencies
RUN sudo apt-get update && apt-get --no-install-recommends -y install git python-pip \
    python-dev python-setuptools libcurl4-openssl-dev libglib2.0-dev \
    libantlr3c-dev libboost-system-dev libboost-filesystem-dev libboost-program-options-dev \
    libboost-program-options-dev libboost-regex-dev cmake antlr3 libhiredis-dev g++ \
    qtbase5-dev llvm libclang-dev redis-server \
    && sudo rm -rf /var/lib/apt/lists/*

WORKDIR /ostis

## Clone projects
RUN git clone --single-branch --branch master https://github.com/ShunkevichDV/ostis.git . && \
    git clone --single-branch --branch scp_stable https://github.com/ShunkevichDV/sc-machine.git && \
    git clone --single-branch --branch master https://github.com/Ivan-Zhukau/sc-web.git && \
    git clone --single-branch --branch master https://github.com/ShunkevichDV/ims.ostis.kb.git

### sc-machine
WORKDIR /ostis/sc-machine/scripts

RUN sudo ./make_all.sh

### sc-web
WORKDIR /ostis/sc-web/scripts

#Install sc-web dependencies
RUN sudo pip install --default-timeout=100 future tornado sqlalchemy redis==2.9 numpy configparser
RUN sudo apt-get update && apt-get --no-install-recommends install -y nodejs-dev node-gyp npm libssl1.0-dev && sudo rm -rf /var/lib/apt/lists/*
RUN sudo npm install -g grunt-cli && npm install && sudo grunt build
## Copy server.conf
WORKDIR /ostis/scripts
RUN sudo cp -f ../config/server.conf ../sc-web/server/

# Prepare kb and problem-solver dirs
WORKDIR /ostis
RUN sudo mv ./ims.ostis.kb/ui/ui_start_sc_element.scs ./kb/ui_start_sc_element.scs \
    && sudo mkdir problem-solver && echo "problem-solver" | sudo tee -a ./repo.path
WORKDIR /ostis/scripts
COPY config /ostis/config

# Copy start container script
COPY scripts/start_container.sh /ostis/scripts

WORKDIR /ostis/scripts
ENTRYPOINT sudo ./start_container.sh

#
# Image config
#
LABEL version="scp_stable"

EXPOSE 8000

