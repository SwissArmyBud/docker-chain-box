
# Setup rigs
$NL="`r`n"
ECHO ${NL}

$CLIENT_PATH="./ETH_GO_CLIENT"

ECHO "[INFO] -> Migrating contracts onto new chain..."
# Use Web3 to migrate
node ./Scripts/ChainJS/migrate.js $CONTRACTS
ECHO ${NL}
