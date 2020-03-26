FROM ubuntu:18.04

#
# Creating image
#
# Add sudo user
RUN apt-get update
RUN apt-get install sudo

RUN adduser --disabled-password --gecos '' docker
RUN adduser docker sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER docker

# Getting sc-machine from repo
WORKDIR /ostis
RUN sudo apt-get -y install git
RUN sudo git clone --single-branch --branch example https://github.com/MikhailSadovsky/sc-machine.git

# Install sc-machine's dependencies
WORKDIR /ostis/sc-machine
RUN sudo echo y | ./scripts/install_deps_ubuntu.sh
RUN sudo apt-get -y install python3-pip
RUN sudo pip3 install -r requirements.txt

# Build sc-machine
WORKDIR /ostis/sc-machine/build
RUN sudo cmake .. -DCMAKE_BUILD_TYPE=Release # use Debug for debug build
RUN sudo make

# Build web interface:
## Install yarn
RUN sudo apt-get -y remove cmdtest
RUN sudo apt-get -y install curl
RUN sudo curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
RUN sudo apt-get -y update
RUN sudo apt-get -y install yarn
## Build
WORKDIR /ostis/sc-machine/web/client
RUN sudo yarn && sudo yarn run webpack-dev

# TODO: Cleanup dependencies

#
# Run sc-server
#
# Build knowledge base (from sc-machine/kb folder)
WORKDIR /ostis/sc-machine/scripts
CMD sudo ./build_kb.sh
# TODO: update client

ENTRYPOINT sudo sh ./run_sc_server.sh

#
# Image config
#
LABEL version="0.6.0"

EXPOSE 8090

