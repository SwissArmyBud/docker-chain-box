
echo "[INFO] -> Beginning token loading into build system..."
echo

### LOAD VARS

echo "[INFO] -> Loading TWILIO_SECRET_TOKEN into env..."
TWILIO_SECRET_TOKEN=""

echo "[INFO] -> Loading TWILIO_SECRET_SID into env..."
TWILIO_SECRET_SID=""

echo "[INFO] -> Loading TWILIO_SECRET_FROM into env..."
TWILIO_SECRET_FROM=""

echo "[INFO] -> Loading TWILIO_SECRET_TO into env..."
TWILIO_SECRET_TO=""

echo "[INFO] -> Loading BUILD_EXPORT_VAR into build context..."
BUILD_EXPORT_VAR="BUILD_EXPORT_VALUE"

### LOAD DONE

echo
echo "[INFO] -> Finished token loading into build system..."
echo
