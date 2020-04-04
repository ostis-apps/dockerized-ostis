#!/bin/sh

cd ../sc-machine/scripts

./make_all.sh

cd ../../scripts

redis-server &
./build_kb.sh

./run_sctp.sh & ./run_scweb.sh
