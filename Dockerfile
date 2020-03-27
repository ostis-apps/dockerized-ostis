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
RUN sudo apt-get -y install git
WORKDIR /ostis
RUN sudo git clone --single-branch --branch 0.5.0 https://github.com/ShunkevichDV/ostis.git .

# Prepare platform
WORKDIR /ostis/scripts
# Fix prepare.sh
## Clone projects
RUN sudo git clone --single-branch --branch 0.5.0 https://github.com/ShunkevichDV/sc-machine.git ../sc-machine
RUN sudo git clone --single-branch --branch master https://github.com/Ivan-Zhukau/sc-web.git ../sc-web
RUN sudo git clone --single-branch --branch master https://github.com/ShunkevichDV/ims.ostis.kb.git ../ims.ostis.kb
RUN sudo apt-get -y install nodejs-dev node-gyp libssl1.0-dev curl python-pip python3
## Prepare projects
### sc-machine
WORKDIR /ostis/sc-machine/scripts
RUN python3Version=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))') && \
    sudo sed -i -e "s/python3.5-dev/python${python3Version}-dev/" ./install_deps_ubuntu.sh && \
    sudo sed -i -e "s/python3.5-dev/python${python3Version}/" ./install_deps_ubuntu.sh
RUN echo y | sudo ./install_deps_ubuntu.sh
RUN sudo apt-get install -y redis-server
#### No need in clean_all.sh
RUN sudo ./make_all.sh
### sc-web
WORKDIR /ostis/sc-web/scripts
RUN sudo pip install --default-timeout=100 future
RUN sudo apt-get install -y python-dev python-setuptools
RUN echo y | sudo ./install_deps_ubuntu.sh
#### Fix node dependencies
RUN sudo apt-get install -y nodejs-dev node-gyp libssl1.0-dev
####
RUN sudo apt-get install -y nodejs npm
RUN sudo ./install_nodejs_dependence.sh
WORKDIR /ostis/sc-web
RUN sudo npm install
RUN sudo grunt build
## Copy server.conf
WORKDIR /ostis/scripts
RUN sudo cp -f ../config/server.conf ../sc-web/server/

# Prepare kb and problem-solver dirs
WORKDIR /ostis
RUN sudo rm ./ims.ostis.kb/ui/ui_start_sc_element.scs
RUN sudo rm -rf ./kb/menu
RUN echo "problem-solver" | sudo tee -a ./repo.path
WORKDIR /ostis/scripts
RUN sudo ./build_kb.sh

# Include kpm
WORKDIR /ostis/sc-machine
#RUN echo 'add_subdirectory(${SC_MACHINE_ROOT}/../../problem-solver/cxx ${SC_MACHINE_ROOT}/bin)' >> ./CMakeLists.txt
RUN echo 'add_subdirectory(${SC_MACHINE_ROOT}/../problem-solver/cxx ${SC_MACHINE_ROOT}/bin)' >> ./CMakeLists.txt
WORKDIR /ostis/sc-machine/scripts
RUN sudo ./make_all.sh

WORKDIR /ostis

# TODO: Cleanup dependencies

#
# Run sc-server
#
# Build knowledge base (from sc-machine/kb folder)
WORKDIR /ostis/sc-machine/scripts
CMD sudo ./build_kb.sh
# TODO: update client

ENTRYPOINT sudo ./restart_sctp.sh & sudo ./run_scweb.sh

#
# Image config
#
LABEL version="0.5.0"

EXPOSE 8000

