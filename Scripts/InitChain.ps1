
# Setup rigs
$NL="`r`n"
ECHO ${NL}

$CLIENT_PATH="./ETH_GO_CLIENT"

# Clean up client path
Remove-Item -Force -Recurse "${CLIENT_PATH}/datadir" -ErrorAction SilentlyContinue
# Do it again, see:
# https://stackoverflow.com/questions/7909167/how-to-quietly-remove-a-directory-with-content-in-powershell#comment10316056_7909195
Remove-Item -Force -Recurse "${CLIENT_PATH}/datadir" -ErrorAction SilentlyContinue

# Get a new blob to lock the accounts
(([guid]::newguid().toString() -replace "[-]" -replace "[ ]")) + "`n" | set-content "${CLIENT_PATH}/datadir/guid.blob" -encoding Ascii
# `
# ^ Formatting tweak, no impact - catches backquote from previous line

# Generate the new accounts and report their values
ECHO "[INFO] -> Generating keys for new chain..."
# Open a new report
(("")) | set-content "${CLIENT_PATH}/accounts.txt" -Encoding Ascii
$TOTAL = $(( [int]$SIGNERS + [int]$FUNDERS + [int]$OWNERS ))
$PREFIX = "SIGNER"
$KEY=0
for ($I=1; $I -le $TOTAL; $I++) {
  $KEY=$I
  if($I -gt $(( [int]$SIGNERS ))){
      $PREFIX="FUNDER"
      $KEY=$(( [int]$I - $(( [int]$SIGNERS )) ))
  }
  if($I -gt $(( [int]$SIGNERS + [int]$FUNDERS ))){
      $PREFIX="OWNER"
      $KEY=$(( [int]$I - $(( [int]$SIGNERS + [int]$FUNDERS )) ))
  }
  ECHO ${NL}
  ECHO "$PREFIX - #$KEY"
  # Create account with key, and rename for purpose
  geth --datadir "${CLIENT_PATH}/datadir" account new --password "${CLIENT_PATH}/datadir/guid.blob"
  mv "${CLIENT_PATH}/datadir/keystore/UTC*" "${CLIENT_PATH}/datadir/keystore/${PREFIX}${KEY}.blob"
  # Log the new account to a readable format for the users
  (("$PREFIX - #$KEY")) | add-content "${CLIENT_PATH}/accounts.txt" -encoding Ascii
  get-content "${CLIENT_PATH}/datadir/keystore/${PREFIX}${KEY}.blob" -raw |
    convertfrom-json |
    select address |
    add-content "${CLIENT_PATH}/accounts.txt" -encoding ascii
  (("")) | add-content "${CLIENT_PATH}/accounts.txt" -encoding Ascii
}
ECHO ${NL}

# TODO - Build appropriate genesis.json file
ECHO "[INFO] -> Generating genesis JSON for new chain..."
ECHO ${NL}
node ./Scripts/ChainJS/genesis.js $SIGNERS $FUNDERS
ECHO ${NL}

# Re-create chain from JSON
ECHO "[INFO] -> Generating genesis block for new chain..."
ECHO ${NL}
geth init "${CLIENT_PATH}/genesis.json" --datadir "${CLIENT_PATH}/datadir"
bootnode -genkey "${CLIENT_PATH}/datadir/geth/nodekey"
$NODEKEYHEX = get-content "${CLIENT_PATH}/datadir/geth/nodekey"
$BOOTNODEID = bootnode -nodekeyhex $NODEKEYHEX -writeaddress
(($BOOTNODEID)) | set-content "${CLIENT_PATH}/datadir/geth/bootkey" -Encoding Ascii
ECHO ${NL}

exit 1
