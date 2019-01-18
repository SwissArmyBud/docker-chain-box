
# Setup rigs
$NL="`r`n"
ECHO ${NL}

$CLIENT_PATH="./ETH_GO_CLIENT"

# Clean up client path
Remove-Item -Force -Recurse "${CLIENT_PATH}/datadir" -ErrorAction SilentlyContinue
# Do it again, see:
# https://stackoverflow.com/questions/7909167/how-to-quietly-remove-a-directory-with-content-in-powershell#comment10316056_7909195
Remove-Item -Force -Recurse "${CLIENT_PATH}/datadir" -ErrorAction SilentlyContinue

# Re-create chain from JSON
geth init "${CLIENT_PATH}/genesis.json" --datadir "${CLIENT_PATH}/datadir"
