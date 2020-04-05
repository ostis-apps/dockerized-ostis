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

# Install OSTIS platform
RUN sudo apt-get -y install git
WORKDIR /
RUN sudo apt-get -y update
RUN sudo apt-get -y upgrade
RUN sudo git clone --single-branch --branch 0.6.0 https://github.com/ShunkevichDV/ostis.git

# Prepare platform
WORKDIR /ostis/scripts
# Fix prepare.sh
## Clone projects
RUN sudo git clone --single-branch --branch 0.6.0 https://github.com/ShunkevichDV/sc-machine.git ../sc-machine
RUN sudo git clone --single-branch --branch 0.6.0 https://github.com/MikhailSadovsky/sc-web.git ../sc-web
RUN sudo git clone --single-branch --branch 0.6.0 https://github.com/ShunkevichDV/ims.ostis.kb.git ../ims.ostis.kb
RUN sudo apt-get -y install nodejs-dev node-gyp libssl1.0-dev curl python-pip python3
## Prepare projects
### sc-machine
WORKDIR /ostis/sc-machine/scripts
RUN python3Version=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))') && \
    sudo sed -i -e "s/python3.5-dev/python${python3Version}-dev/" ./install_deps_ubuntu.sh && \
    sudo sed -i -e "s/python3.5-dev/python${python3Version}/" ./install_deps_ubuntu.sh
RUN echo y | sudo ./install_deps_ubuntu.sh
WORKDIR /ostis/sc-machine
RUN pip3 install -r requirements.txt
WORKDIR /ostis/sc-machine/scripts
RUN sudo ./make_all.sh; exit 0
RUN cat ../bin/config.ini | sudo tee -a ../../config/sc-web.ini
### sc-server web
RUN sudo apt-get remove -y cmdtest
RUN sudo apt-get remove -y yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
RUN sudo apt-get update
RUN sudo apt-get install -y yarn
WORKDIR /ostis/sc-machine/web/client
RUN sudo yarn && sudo yarn run webpack-dev
### sc-web
WORKDIR /ostis/sc-web/scripts   
RUN sudo pip3 install --default-timeout=100 future
RUN sudo apt-get install python-setuptools
RUN sudo apt-get install -y nodejs-dev node-gyp libssl1.0-dev
RUN sudo ./install_deps_ubuntu.sh
RUN echo y | sudo ./install_nodejs_dependence.sh
WORKDIR /ostis/sc-web
RUN sudo npm install
RUN sudo grunt build
## Copy server.conf
WORKDIR /ostis/scripts
RUN sudo cp -f ../config/server.conf ../sc-web/server/

# Include kb
WORKDIR /ostis
RUN sudo rm ./ims.ostis.kb/ui/ui_start_sc_element.scs
RUN sudo rm -rf ./kb/menu
RUN echo "kb" | sudo tee -a ./repo.path
RUN echo "problem-solver" | sudo tee -a ./repo.path

# Include kpm
WORKDIR /ostis/sc-machine
RUN echo 'add_subdirectory(${SC_MACHINE_ROOT}/../../problem-solver/cxx ${SC_MACHINE_ROOT}/bin)' | sudo tee -a ./CMakeLists.txt
WORKDIR /ostis/sc-machine/scripts
RUN sudo ./make_all.sh; exit 0

# TODO: Cleanup dependencies

#
# Run sc-server
#
# TODO: update client
COPY scripts/start_container.sh /ostis/scripts

WORKDIR /ostis/scripts
ENTRYPOINT sudo ./start_container.sh

#
# Image config
#
LABEL version="0.6.0"

EXPOSE 8090

