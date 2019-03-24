
echo "[INFO] -> Migrating contracts onto new chain..."
# Use Web3 to migrate
node ${shScriptRoot}/Scripts/ChainJS/migrate.js $CONTRACTS
for (( I=1; I<=3; I++ ))
do
  node ${shScriptRoot}/Scripts/ChainJS/migrate.js $CONTRACTS
  EXIT_CODE=$?
  if [ $EXIT_CODE -eq 0 ]; then
    I=4
  else
    sleep 1
  fi
done
echo
