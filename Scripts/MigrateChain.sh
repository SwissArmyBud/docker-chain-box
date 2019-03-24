
echo "[INFO] -> Migrating contracts onto new chain..."
# Use Web3 to migrate
EXIT_CODE=0
for (( I=1; I<=3; I++ ))
do
  node ${shScriptRoot}/Scripts/ChainJS/migrate.js $CONTRACTS
  EXIT_CODE=$?
  echo "[INFO] -> Migration exit code is: $EXIT_CODE"
  if [ $EXIT_CODE -eq 0 ]; then
    I=4
  else
    sleep 5
    rm ${shScriptRoot}/Projects/ETH_GO_CLIENT/datadir/geth.ipc
  fi
done
echo
if [ $EXIT_CODE -ne 0 ]; then
  echo "[INFO] -> Migration failed after restart attempts!"
  exit $EXIT_CODE
fi
