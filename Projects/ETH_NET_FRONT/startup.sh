
echo "[INFO] -> Startup script beginning..."
echo

ls /app 1>/dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "[SETUP] -> Unpacking application..."
  tar -xzf app.tar.gz
  rm -f app.tar.gz
fi
echo

echo "[CONF] -> Putty variable values are:"
echo "[CONF] -> Export value from Builder = $BUILD_EXPORT_PUTTY"
echo "[CONF] -> Export value from Composer = $COMPOSE_EXPORT_PUTTY"

echo "[CONF] -> Setting ENV variables for server..."
export WS_SECRET="socketsecret2"
export PORT="3010"
echo

echo "[INFO] -> Starting application..."
node /app/bin/www
echo
