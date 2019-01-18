
# Setup rigs
$NL="`r`n"
ECHO ${NL}

ECHO "[INFO] -> Beginning token loading into build system..."
ECHO ${NL}

### LOAD VARS

ECHO "[INFO] -> Loading TWILIO_SECRET_TOKEN into env..."
$TWILIO_SECRET_TOKEN = ""

ECHO "[INFO] -> Loading TWILIO_SECRET_SID into env..."
$TWILIO_SECRET_SID = ""

ECHO "[INFO] -> Loading TWILIO_SECRET_FROM into env..."
$TWILIO_SECRET_FROM = ""

ECHO "[INFO] -> Loading TWILIO_SECRET_TO into env..."
$TWILIO_SECRET_TO = ""

ECHO "[INFO] -> Loading BUILD_EXPORT_VAR into build context..."
$BUILD_EXPORT_VAR = "BUILD_EXPORT_VALUE"

### LOAD DONE

ECHO ${NL}
ECHO "[INFO] -> Finished token loading into build system..."
ECHO ${NL}
