FROM ubuntu:18.04

#
# Creating image
#
# Add sudo user
RUN apt-get update && apt-get install -y sudo

USER root

# Getting dependencies
RUN sudo apt-get update && apt-get -y install git redis-server python3-pip python3 qtbase5-dev openjdk-11-jre openjdk-11-jdk curl \
    && sudo rm -rf /var/lib/apt/lists/*

WORKDIR /ostis

## Clone projects
RUN git clone --single-branch --branch 0.6.0 https://github.com/ostis-dev/ostis-web-platform.git . && \
    git clone --single-branch --branch 0.6.0 https://github.com/ShunkevichDV/sc-machine.git && \
    git clone --single-branch --branch 0.6.0 https://github.com/ostis-dev/sc-web.git && \
    git clone --single-branch --branch 0.6.0 https://github.com/ShunkevichDV/ims.ostis.kb.git

### sc-machine
WORKDIR /ostis/sc-machine/scripts
RUN python3Version=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))') && \
    sudo sed -i -e "s/python3.5-dev/python${python3Version}-dev/" ./install_deps_ubuntu.sh && \
    sudo sed -i -e "s/python3.5-dev/python${python3Version}/" ./install_deps_ubuntu.sh && \
    sudo apt-get update && echo y | sudo ./install_deps_ubuntu.sh && \
    sudo rm -rf /var/lib/apt/lists/*

WORKDIR /ostis/sc-machine

RUN python3 -m pip install -r requirements.txt

WORKDIR /ostis/sc-machine/scripts
RUN sudo ./make_all.sh
RUN cat ../bin/config.ini | sudo tee -a ../../config/sc-web.ini

### sc-server web
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list && \
    sudo apt-get update && sudo apt-get install -y yarn && sudo rm -rf /var/lib/apt/lists/*

WORKDIR /ostis/sc-machine/web/client
RUN sudo yarn

### sc-web
WORKDIR /ostis/sc-web/scripts   

#Install sc-web dependencies
RUN sudo apt-get update && \
    #workaround for python-rocksdb to build on outdated wheel and setuptools of 18.04 
    echo y | python3 -m pip install -U pip setuptools wheel tqdm && \ 
    #workadround to install node and npm (node-gyp doesn't install itself as a dep on 18.04) 
    sudo apt-get install -y nodejs-dev node-gyp libssl1.0-dev && \ 
    sudo ./install_deps_ubuntu.sh && \
    sudo ./install_nodejs_dependence.sh && \
    npm install && sudo grunt build

# Copy server.conf
WORKDIR /ostis/scripts
RUN sudo cp -f ../config/server.conf ../sc-web/server/

# Include kb
WORKDIR /ostis
RUN sudo mkdir kb && sudo mv ./ims.ostis.kb/ui/ui_start_sc_element.scs ./kb/ui_start_sc_element.scs && \
    sudo mv ./ims.ostis.kb/ui/menu ./kb && echo "kb" | sudo tee -a ./repo.path && sudo mkdir -p problem-solver/cxx && \
    echo "problem-solver" | sudo tee -a ./repo.path

# Include kpm
WORKDIR /ostis/sc-machine
RUN sudo apt-get update && sudo apt-get --no-install-recommends install -y libcurl4-openssl-dev && \
    echo 'if (EXISTS "${SC_MACHINE_ROOT}/../problem-solver/cxx/CMakeLists.txt")\n add_subdirectory(${SC_MACHINE_ROOT}/../problem-solver/cxx ${SC_MACHINE_ROOT}/bin)\n endif()' | sudo tee -a ./CMakeLists.txt

# Copy start container script
COPY scripts/ostis /ostis/scripts/

WORKDIR /ostis/scripts

#
# Image config
#
LABEL version="0.6.0"

EXPOSE 8090
EXPOSE 8000
EXPOSE 55770

