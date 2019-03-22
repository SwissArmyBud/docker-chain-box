
echo "[INFO] -> Migrating contracts onto new chain..."
# Use Web3 to migrate
node ${SHScriptRoot}/Scripts/ChainJS/migrate.js $CONTRACTS
echo
