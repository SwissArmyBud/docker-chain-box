param(
  [string]$chain = "DEFAULT VAL",
  [string]$signers = "1",
  [string]$funders = "1",
  [string]$owners = "1",
  [string]$contracts = "TournamentMatches,TournamentPrizewall"
)
# See:
# https://stackoverflow.com/a/43351197
if(!$psScriptRoot){ $psScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

# Start timer
$BUILD_TIMER =  [system.diagnostics.stopwatch]::StartNew()

# Setup rigs
$NL="`r`n"
ECHO ${NL}

$WORKING_DIR = PWD
$CHAIN_TYPE = $CHAIN

# Load tokens
. $psScriptRoot/Scripts/BuildTokenLoader.ps1
echo "$BUILD_EXPORT_VAR"
ECHO ${NL}

if(!$CHAIN_TYPE){
  ECHO "[CRIT] -> Failed to specify chain action, exiting!"
  exit 1
} else {
  switch ($CHAIN_TYPE.toLower()){
    "fresh" {
      ECHO "[INFO] -> Building new chain for project..."
      ECHO "[INFO] -> Chain has $SIGNERS signers..."
      ECHO "[INFO] -> Chain has $FUNDERS funders..."
      ECHO "[INFO] -> Chain has $OWNERS owners..."
      # Run chain init
      . $psScriptRoot/Scripts/InitChain.ps1
      $CONTRACT_COUNT = 0
      if ($CONTRACTS.length -ne 0) {
        $CONTRACT_COUNT = $CONTRACTS.Split(",").count
      }
      # Run chain fill
      ECHO "[INFO] -> Chain has $CONTRACT_COUNT contracts..."
      if ($CONTRACT_COUNT -ne 0) {
        . $psScriptRoot/Scripts/MigrateChain.ps1
      }
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
. $psScriptRoot/Scripts/BuildRunner.ps1
ECHO ${NL}

# Stop the stopwatch and report its time
$BUILD_TIMER.Stop()
$BUILD_TIMER = [math]::Round($BUILD_TIMER.Elapsed.TotalSeconds,0)
ECHO "[TIME] --> Build took: $BUILD_TIMER seconds..."
ECHO ${NL}${NL}

# Notify via Twilio that we have finished
. $psScriptRoot/Scripts/TwilioNotifier.ps1 -text "Project has finished building! Back to work!"
ECHO ${NL}
