#!/bin/sh

sudo ../sc-machine/scripts/make_all.sh

sudo redis-server & wait && \
sudo ./run_sctp.sh & sudo ./run_scweb.sh
