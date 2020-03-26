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
RUN sudo apt-get -y install nodejs-dev node-gyp libssl1.0-dev
WORKDIR /ostis
RUN sudo ./scripts/prepare.sh

# Prepare kb and problem-solver dirs
WORKDIR /ostis
RUN rm ./ims.ostis.kb/ui/ui_start_sc_element.scs
RUN rm -rf ./kb/menu
RUN echo "./kb" >> ./repo.path
RUN echo "./problem-solver" >> ./repo.path

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

