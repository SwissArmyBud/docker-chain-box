
echo "[INFO] -> Startup script beginning..."
echo

ls /app 1>/dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "[SETUP] -> Unpacking application..."
  tar -xzf bins.tar.gz
  rm -f bins.tar.gz
  ls  /app/nodekey 1>/dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo "[INFO] -> Generating nodekey for gEth..."
    bootnode -genkey /app/nodekey
  fi
fi
echo

echo "[INFO] -> Bootkey: $(bootnode -nodekey /app/nodekey -writeaddress)"
echo

echo "[INFO] -> Starting gEth application..."
RAND=$(</dev/urandom tr -dc 0-9 | head -c 4)
IEX="geth \
--nodekey /app/nodekey \
--datadir /app/datadir \
--ethstats DockerNode-$RAND:socketsecret2@eth_net_front:3010 \
"
echo "[CMD] -> $IEX"
echo $@
echo

$IEX
echo "[INFO] -> Exiting gEth..."
echo
