#!/bin/bash
CHAIN="DEFAULT VAL"
SIGNERS="1"
FUNDERS="1"
OWNERS="1"
CONTRACTS="TournamentMatches,TournamentPrizewall"
while getopts ":n:s:f:o:c:" opt; do
  case $opt in
    n) CHAIN="$OPTARG"
    ;;
    s) SIGNERS="$OPTARG"
    ;;
    f) FUNDERS="$OPTARG"
    ;;
    o) OWNERS="$OPTARG"
    ;;
    c) CONTRACTS="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done

# See:
# https://stackoverflow.com/a/246128
shScriptRoot=$( cd $( dirname ${BASH_SOURCE[0]} ) >/dev/null 2>&1 && pwd )

# Start timer
BUILD_TIMER=$SECONDS

WORKING_DIR=$(pwd)
CHAIN_TYPE=$CHAIN

# Load tokens
source ${shScriptRoot}/Scripts/BuildTokenLoader.sh
echo $BUILD_EXPORT_VAR
echo

if [ -v $CHAIN_TYPE ]; then
  echo "[CRIT] -> Failed to specify chain action, exiting!"
  exit 1
else
  case $(echo $CHAIN_TYPE | tr '[:upper:]' '[:lower:]') in
    fresh)
      echo "[INFO] -> Building new chain for project..."
      echo "[INFO] -> Chain has $SIGNERS signers..."
      echo "[INFO] -> Chain has $FUNDERS funders..."
      echo "[INFO] -> Chain has $OWNERS owners..."
      # Run chain init
      source ${shScriptRoot}/Scripts/InitChain.sh
      CONTRACT_COUNT=0
      if [ -v $CONTRACTS ]; then
        # Leave contract count alone if no contract value
      else
        CONTRACT_COUNT=$(( $(echo $CONTRACTS | grep -o "," | wc -l) + 1 ))
      fi
      # Migrate contracts if needed
      if [ $CONTRACT_COUNT -gt 0 ]; then
        echo "[INFO] -> Chain has $CONTRACT_COUNT contracts..."
        source ${shScriptRoot}/Scripts/MigrateChain.sh
      fi
      ;;

    stale)
      echo "[INFO] -> Using existing chain for project..."
      ;;

    *)
      echo "[CRIT] -> Unknown chain param, use stale or fresh!"
      exit 1

  esac
fi
echo

# Build the tournament containers
source ${shScriptRoot}/Scripts/BuildRunner.sh
echo

# Stop the stopwatch and report its time
BUILD_TIMER=$(( SECONDS - BUILD_TIMER ))
echo "[TIME] --> Build took: $BUILD_TIMER seconds..."
echo
echo

# Notify via Twilio that we have finished
# source ${shScriptRoot}/Scripts/TwilioNotifier.sh -text "Project has finished building! Back to work!"
echo
