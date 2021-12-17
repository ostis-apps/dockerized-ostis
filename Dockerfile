FROM debian:bullseye-slim as base 

USER root

#runtime dependencies required for building cxx problem-solvers and scripts
RUN apt update && apt --no-install-recommends -y install python3-pip python3.9 libpython3.9 curl g++ cmake make
#Libs required in runtime
RUN apt --no-install-recommends -y install librocksdb6.11 libboost-system1.74.0 libboost-filesystem1.74.0 python3-rocksdb libboost-python1.74.0 libboost-program-options1.74.0 libglib2.0-0 libqt5network5


#Install sc-web runtime dependencies
RUN python3 -m pip install --no-cache-dir --default-timeout=100 future tornado sqlalchemy numpy configparser progress 

#Installing python runtime deps for sc-machine
RUN python3 -m pip install --no-cache-dir termcolor tornado 
#Derived from debian and not "base" image because any change in base would cache bust the build environment
FROM debian:bullseye-slim AS buildenv
#Install build-time deps
RUN apt update && apt -y install qtbase5-dev git librocksdb-dev libglib2.0-dev libboost-system-dev libboost-filesystem-dev libboost-program-options-dev make cmake antlr gcc g++ llvm libcurl4-openssl-dev libclang-dev libboost-python-dev python3-dev python3-pip curl python3-rocksdb redis-server 

WORKDIR /ostis


## Clone projects
RUN git clone --single-branch --branch 0.6.0 --depth 1 https://github.com/ostis-dev/ostis-web-platform.git . && \
    git clone --single-branch --branch 0.6.0 --depth 1 https://github.com/ShunkevichDV/sc-machine.git && \
	git clone --single-branch --branch 0.6.0 --depth 1 https://github.com/ostis-dev/sc-web.git && \
	git clone --single-branch --branch 0.6.0 --depth 1 https://github.com/ShunkevichDV/ims.ostis.kb.git

### sc-machine
WORKDIR /ostis/sc-machine

#Building sc-machine
WORKDIR /ostis/sc-machine/scripts
RUN ./make_all.sh
RUN cat ../bin/config.ini | tee -a ../../config/sc-web.ini

###File operations
# Include kb
WORKDIR /ostis
RUN mkdir kb && mv ./ims.ostis.kb/ui/ui_start_sc_element.scs ./kb/ui_start_sc_element.scs && \
    mv ./ims.ostis.kb/ui/menu ./kb && echo "kb" | tee -a ./repo.path && mkdir -p problem-solver/cxx && \
    echo "problem-solver" | tee -a ./repo.path

# Copy server.conf
WORKDIR /ostis/scripts
RUN cp -f ../config/server.conf ../sc-web/server/

#Deleting the new web interface as we're not using it
RUN rm -rf /ostis/sc-machine/web

### sc-web
FROM node:16-alpine AS web-buildenv

COPY --from=buildenv /ostis/sc-web /sc-web
WORKDIR /sc-web   

#Install sc-web build-time dependencies
RUN npm install -g grunt-cli
#Build sc-web
RUN npm install && grunt build


#Gathering all artifacts together
FROM base AS final

COPY --from=buildenv /ostis /ostis
COPY --from=web-buildenv /sc-web /ostis/sc-web


# Copy start container script
COPY scripts/ostis /ostis/scripts/

#
# Image config
#
LABEL version="0.6.0"

EXPOSE 8000
EXPOSE 55770
ENTRYPOINT ["/ostis/scripts/ostis"]
CMD ["--all"]
