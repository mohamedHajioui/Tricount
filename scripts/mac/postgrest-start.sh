#!/bin/bash

cd $(dirname "$0")
echo "Le script s'exécute dans : $(pwd)"

source $(dirname "$0")/env.sh

if [ ! -d "../../data" ]; then
    source $(dirname "$0")/pg-init.sh
else
    source $(dirname "$0")/pg-start.sh
fi

sleep 3

postgrest ../../postgrest.conf