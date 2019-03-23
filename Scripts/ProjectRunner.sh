#!/bin/bash

shScriptRoot=$( cd $( dirname ${BASH_SOURCE[0]} ) >/dev/null 2>&1 && pwd )

# Load tokens
source ${shScriptRoot}/scripts/ComposeTokenLoader.sh
echo

# Get all images and import
for IMAGE in "${shScriptRoot}/images"/*
do
  $IEX_CMD = "docker load --input ${shScriptRoot}/images/$IMAGE"
  echo "COMMAND -> $IEX_CMD"
  $IEX_CMD
done

# Start the actual service cluster
docker-compose up
