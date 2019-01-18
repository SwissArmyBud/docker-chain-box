param([string]$chain = "DEFAULT VAL")
# See:
# https://stackoverflow.com/a/43351197
if(!$PSScriptRoot){ $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

# Setup rigs
$NL="`r`n"
ECHO ${NL}

$WORKING_DIR = PWD
$CHAIN_TYPE = $CHAIN

# Load tokens
. $PSScriptRoot/Scripts/BuildTokenLoader.ps1
echo "$BUILD_EXPORT_VAR"
ECHO ${NL}

if(!$CHAIN_TYPE){
  ECHO "[CRIT] -> Failed to specify chain action, exiting!"
  exit 1
} else {
  switch ($CHAIN_TYPE.toLower()){
    "fresh" {
      ECHO "[INFO] -> Building new chain for project..."
      . $PSScriptRoot/Scripts/WinInitChain.ps1
      break
    }
    "stale" {
      ECHO "[INFO] -> Using existing chain for project..."
      break
    }
    default {
      ECHO "[CRIT] -> Unknown chain param, use stale or fresh!"
      exit 1
    }
  }
}
ECHO ${NL}

# Build the tournament containers
. $PSScriptRoot/Scripts/WinBuildRunner.ps1
ECHO ${NL}

# Notify via Twilio that we have finished
. $PSScriptRoot/Scripts/TwilioNotifier.ps1 -text "Project has finished building! Back to work!"
ECHO ${NL}
