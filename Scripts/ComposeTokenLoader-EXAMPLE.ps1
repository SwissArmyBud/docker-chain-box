
# Setup rigs
$NL="`r`n"
ECHO ${NL}

ECHO "[INFO] -> Beginning token loading into env..."
ECHO ${NL}

### LOAD VARS

# Ensure Docker-Compose has access through env, see:
# https://github.com/docker/compose/issues/4189#issuecomment-320362242
ECHO "[INFO] -> Loading COMPOSE_EXPORT_VAR into host env..."
$env:COMPOSE_EXPORT_VAR = "COMPOSE_EXPORT_VALUE"
$env:COMPOSE_NODE_PASS = "<YOUR GUID BLOB HERE>"
### LOAD DONE

ECHO ${NL}
ECHO "[INFO] -> Finished token loading into env..."
ECHO ${NL}
