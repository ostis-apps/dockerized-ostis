#!/bin/sh

./build_kb.sh

cd ../sc-machine/scripts

./make_all.sh

cd ../../scripts

./run_sctp.sh &

echo "\n\e[1;32mStarting the old sc-web on http://localhost:8000 and the new on http://localhost:8090...\e[0m\n"

./run_scweb.sh

