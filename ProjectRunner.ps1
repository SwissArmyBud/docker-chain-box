
# See:
# https://stackoverflow.com/a/43351197
if(!$PSScriptRoot){ $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

# Setup rigs
$NL="`r`n"
ECHO ${NL}

# Load tokens
. $PSScriptRoot/Scripts/ComposeTokenLoader.ps1
ECHO ${NL}

# Start the actual service cluster
docker-compose up
