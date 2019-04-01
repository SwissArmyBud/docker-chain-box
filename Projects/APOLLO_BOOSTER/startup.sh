
echo "[INFO] -> Startup script beginning..."
echo

ls /app 1>/dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "[SETUP] -> Unpacking application..."
  tar -xzf app.tar.gz
  rm -f app.tar.gz
  echo "[SETUP] -> Configuring application..."
  mkdir -p /app/pgsql/log
  mkdir -p /run/postgresql
  mkdir -p /app/conf && mv /app.conf /app/conf/app.conf && rm -f /app.conf
  sed -i 's/dev/dep/g' /app/conf/app.conf
  mv /env /.env && rm -f /env
  echo "[SETUP] -> Resetting permissions..."
  chown -R postgres /app/pgsql /run/postgresql
  echo "[SETUP] -> Cleaning up..."
fi
echo

echo "[INFO] -> Starting PostgreSQL database..."
su postgres -c "pg_ctl -D /app/pgsql/data -l /app/pgsql/log/start.log start"
echo

echo "[INFO] -> Starting Apollo booster..."
/app/apollo
echo "[INFO] -> Shutting down Apollo booster..."
echo
