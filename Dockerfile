FROM ubuntu:18.04

#
# Creating image
#
# Add sudo user
RUN apt-get update && apt-get install -y sudo

USER root

# Getting dependencies
RUN sudo apt-get update && apt-get -y install git redis-server python-pip python3 \
    && sudo rm -rf /var/lib/apt/lists/*

WORKDIR /ostis

## Clone projects
RUN git clone --single-branch --branch 0.5.0 https://github.com/ShunkevichDV/ostis.git . && \
    git clone --single-branch --branch 0.5.0 https://github.com/ShunkevichDV/sc-machine.git && \
    git clone --single-branch --branch master https://github.com/Ivan-Zhukau/sc-web.git && \
    git clone --single-branch --branch master https://github.com/ShunkevichDV/ims.ostis.kb.git

### sc-machine
WORKDIR /ostis/sc-machine/scripts
RUN python3Version=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))') && \
    sudo sed -i -e "s/python3.5-dev/python${python3Version}-dev/" ./install_deps_ubuntu.sh && \
    sudo sed -i -e "s/python3.5-dev/python${python3Version}/" ./install_deps_ubuntu.sh && \
    sudo apt-get update && echo y | sudo ./install_deps_ubuntu.sh && \
    sudo rm -rf /var/lib/apt/lists/*
RUN ./make_all.sh

### sc-web
WORKDIR /ostis/sc-web/scripts

#Install sc-web dependencies
RUN sudo pip install --default-timeout=100 future tornado sqlalchemy redis==2.9 numpy configparser && \
    sudo apt-get update && apt-get --no-install-recommends install -y nodejs-dev node-gyp npm libssl1.0-dev && \
    sudo rm -rf /var/lib/apt/lists/* && sudo npm install -g grunt-cli && npm install && sudo grunt build
## Copy server.conf
WORKDIR /ostis/scripts
RUN sudo cp -f ../config/server.conf ../sc-web/server/

# Prepare kb and problem-solver dirs
WORKDIR /ostis
RUN sudo mv ./ims.ostis.kb/ui/ui_start_sc_element.scs ./kb/ui_start_sc_element.scs && \
    sudo mkdir -p problem-solver/cxx && echo "problem-solver" | sudo tee -a ./repo.path
WORKDIR /ostis/scripts
COPY config /ostis/config

# Include kpm
WORKDIR /ostis/sc-machine
RUN sudo apt-get update && sudo apt-get --no-install-recommends install -y libcurl4-openssl-dev && \
    echo 'add_subdirectory(${SC_MACHINE_ROOT}/../problem-solver/cxx ${SC_MACHINE_ROOT}/bin)' | sudo tee -a ./CMakeLists.txt

# Copy start container script
COPY scripts/start_container.sh /ostis/scripts

WORKDIR /ostis/scripts
ENTRYPOINT sudo ./start_container.sh

#
# Image config
#
LABEL version="0.5.0"

EXPOSE 8000

