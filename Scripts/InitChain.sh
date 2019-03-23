
CLIENT_PATH="${shScriptRoot}/ETH_GO_CLIENT"

# Clean up client path
rm -r -f "${CLIENT_PATH}/datadir"

# Get a new blob to lock the accounts
rm "${shScriptRoot}${CLIENT_PATH}/guid.blob" 2>/dev/null
echo $( cat /proc/sys/kernel/random/uuid | sed -e "s/[[:punct:]]\+//g" ) > "${CLIENT_PATH}/guid.blob"

# Generate the new accounts and report their values
echo "[INFO] -> Generating keys for new chain..."
# Open a new report
rm "${CLIENT_PATH}/accounts.txt" 2>/dev/null
touch "${CLIENT_PATH}/accounts.txt"
TOTAL=$(( $SIGNERS + $FUNDERS + $OWNERS ))
PREFIX="SIGNER"
KEY=0
for (( I=1; I<=$TOTAL; I++ ))
do
  KEY=$I
  if [[ $I -gt $SIGNERS ]]; then
    PREFIX="FUNDER"
    KEY=$(( $I - $SIGNERS ))
  fi
  if [[ $I -gt $(( $SIGNERS + $FUNDERS )) ]]; then
    PREFIX="OWNER"
    KEY=$(( $I - $(( $SIGNERS + $FUNDERS )) ))
  fi
  echo
  echo "$PREFIX - #$KEY"
  # Create account with key, and rename for purpose
  geth --datadir "${CLIENT_PATH}/datadir" account new --password "${CLIENT_PATH}/guid.blob"
  mv ${CLIENT_PATH}/datadir/keystore/UTC* "${CLIENT_PATH}/datadir/keystore/${PREFIX}${KEY}.blob"
  # Log the new account to a readable format for the users
  echo "$PREFIX - #$KEY" >> "${CLIENT_PATH}/accounts.txt"
  echo "@{address=$(grep -Po '"address":"\K.*?(?=")' "${CLIENT_PATH}/datadir/keystore/${PREFIX}${KEY}.blob")}" >> "${CLIENT_PATH}/accounts.txt"
  echo >> "${CLIENT_PATH}/accounts.txt"
done
echo

# TODO - Build appropriate genesis.json file
echo "[INFO] -> Generating genesis JSON for new chain..."
echo
node "${shScriptRoot}/Scripts/ChainJS/genesis.js" $SIGNERS $FUNDERS
echo

# Re-create chain from JSON
echo "[INFO] -> Generating genesis block for new chain..."
echo
geth init "${CLIENT_PATH}/genesis.json" --datadir "${CLIENT_PATH}/datadir"
bootnode -genkey "${CLIENT_PATH}/datadir/geth/nodekey"
echo $(bootnode -nodekeyhex $(cat "${CLIENT_PATH}/datadir/geth/nodekey") -writeaddress) > "${CLIENT_PATH}/datadir/geth/bootkey"
echo
