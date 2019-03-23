
# Setup rigs
$NL="`r`n"
ECHO ${NL}

# Load tokens
. $PSScriptRoot/scripts/ComposeTokenLoader.ps1
ECHO ${NL}

# Get all images and import
Get-ChildItem ./images |
    ForEach-Object {
        $IEX_CMD = "docker load --input $PSScriptRoot/images/$_"
        echo "COMMAND -> $IEX_CMD"
        iex $IEX_CMD
    }
# Start the actual service cluster
docker-compose up
