
# Setup rigs
$NL="`r`n"
ECHO ${NL}

# Load tokens
. ./scripts/ComposeTokenLoader.ps1
ECHO ${NL}

# Get all images and import
$IMAGES = Get-ChildItem ./images
$LOADED = $(docker images --filter=reference="tournament/*" --format "{{.Repository}}").Split([Environment]::NewLine)
$IMAGES | ForEach-Object {
        $TAG = $( "tournament/" + $_.BaseName )
        if(! $LOADED.contains($TAG) ) {
            $IEX_CMD = "docker load --input ./images/$_"
            echo "LOADING --> $TAG"
            iex $IEX_CMD
        } else {
            echo "FOUND CACHED --> $TAG"
        }
    }
# Start the actual service cluster
docker-compose up
