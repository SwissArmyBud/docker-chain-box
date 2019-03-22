
# Setup rigs
$NL="`r`n"
ECHO ${NL}

# Load tokens
. $PSScriptRoot/Scripts/ComposeTokenLoader.ps1
ECHO ${NL}

# Get all images and import
Get-ChildItem ./Images |
    ForEach-Object {
        $IEX_CMD = "docker load --input $PSScriptRoot/Images/$_"
        echo "COMMAND -> $IEX_CMD"
        iex $IEX_CMD
    }
# Start the actual service cluster
docker-compose up
