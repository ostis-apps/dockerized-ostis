#!/bin/sh

cd /ostis/sc-machine/scripts
./make_all.sh

cd /ostis/scripts
redis-server &
./build_kb.sh

./run_sctp.sh &
echo "\n\e[1;32mStarting sc-web on http://localhost:8000...\e[0m\n"
./run_scweb.sh

