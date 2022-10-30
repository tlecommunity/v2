#!/bin/bash
export PATH=/data/apps/bin:$PATH
cd /home/lacuna/server/bin
perl generate_docs.pl > /dev/null
killall -HUP start_server
