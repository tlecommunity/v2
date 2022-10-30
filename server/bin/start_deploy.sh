#!/bin/bash
export PATH=/data/apps/bin:$PATH
cd /home/lacuna/server/bin
start_server --port 5001 -- starman --workers 1 --user nobody --group nobody --preload-app deploy.psgi &
