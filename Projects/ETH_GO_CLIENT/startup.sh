
echo "[INFO] -> Startup script beginning..."
echo

which geth 1>/dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "[SETUP] -> Unpacking application..."
  tar -xzf bins.tar.gz
  rm -f bins.tar.gz
fi
echo

echo "Geth node type is: $GETH_NODE_TYPE"
if [ $GETH_NODE_TYPE != "MASTER" ]; then
  echo "[INFO] -> Generating nodekey for gEth..."
  bootnode -genkey /app/datadir/geth/nodekey
fi
echo

echo "[INFO] -> Bootkey: $(bootnode -nodekey /app/datadir/geth/nodekey -writeaddress)"
echo

echo "[INFO] -> Starting gEth application..."
RAND=$(</dev/urandom tr -dc 0-9 | head -c 4)
ACCOUNT_ADDRESS=$(sed -n 's/{"address":"\([0-9a-zA-Z]*\)".*/\1/p' /app/datadir/keystore/SIGNER1.blob)
IEX="geth \
--nodekey /app/datadir/geth/nodekey \
--datadir /app/datadir \
--unlock $ACCOUNT_ADDRESS \
--password /app/datadir/guid.blob \
--ethstats DockerNode-$RAND:socketsecret2@eth_net_front:3010 \
--mine \
"
echo "[CMD] -> $IEX"
echo $@
echo

$IEX
echo "[INFO] -> Exiting gEth..."
echo
