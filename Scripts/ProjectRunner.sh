#!/bin/bash

shScriptRoot=$( cd $( dirname ${BASH_SOURCE[0]} ) >/dev/null 2>&1 && pwd )

# Load tokens
source ${shScriptRoot}/Scripts/ComposeTokenLoader.ps1
echo

# Get all images and import
for IMAGE in "${shScriptRoot}/Images"/*
do
  $IEX_CMD = "docker load --input ${shScriptRoot}/Images/$IMAGE"
  echo "COMMAND -> $IEX_CMD"
  $IEX_CMD
done

# Start the actual service cluster
docker-compose up
