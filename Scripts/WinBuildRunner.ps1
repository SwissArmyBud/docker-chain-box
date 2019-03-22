
# See:
# https://stackoverflow.com/a/43351197
if(!$PSScriptRoot){ $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }
ECHO $PSScriptRoot

# Setup rigs
$NL="`r`n"
ECHO ${NL}

# Grab current folder layout
$DOCKER_PROJECTS = Get-ChildItem -dir |
  ForEach-Object { if( ($_.Name -ne "Tournament") -and
                       ($_.Name -ne "Scripts")    ){
                        $_.Name.ToLower()
                      }
                  }
ECHO "Building the following projects: $DOCKER_PROJECTS"
ECHO ${NL}

# Create build directory
if(Test-Path ./Tournament){
  Remove-Item  -Recurse -Path ./Tournament
}
New-Item -ItemType directory -Path ./Tournament
New-Item -ItemType directory -Path ./Tournament/Images

# Build and export images for each project
foreach($PROJECT in $DOCKER_PROJECTS) {
# Alert and move into project
  ECHO "[INFO] -> Starting project: $PROJECT"
  Set-Location -Path ./$PROJECT
  ECHO ${NL}

# Build new image for stack
  $BUILD_STRING = "docker build -t tournament/${PROJECT}:latest ."
  if(Test-Path ./DockerArgs){
    foreach($line in Get-Content ./DockerArgs) {
      $BUILD_STRING = "$BUILD_STRING --build-arg $line"
    }
  }
  echo "[INFO] -> Starting docker build for: $PROJECT"
  echo $BUILD_STRING
  Invoke-Expression ${BUILD_STRING}
  ECHO ${NL}

# Leave project
  echo "[INFO] -> Finished tasks for: $PROJECT"
  Set-Location -Path ../
  ECHO ${NL}

# Output the image for stack
  echo "[INFO] -> Starting image export for: $PROJECT"
  docker save -o ./Tournament/Images/${PROJECT}.zip tournament/${PROJECT}:latest
  ECHO ${NL}
}

# Todo - Split this off into a project-manageable section for decoupling
# Currently the assumption is that ETH_GO_CLIENT is indeed being build/packed
# Move composer to build directory
Copy-Item ./docker-compose.yaml -Destination ./Tournament
# Move compose-time token loader to build
Copy-Item ./Scripts/ComposeTokenLoader.ps1 -Destination ./Tournament
# Move runner to build
Copy-Item ./Scripts/ProjectRunner.ps1 -Destination ./Tournament
# Move chain to build
Copy-Item ./ETH_GO_CLIENT/datadir -Destination ./Tournament/datadir -Recurse
# Move chain read-outs to build
Copy-Item ./ETH_GO_CLIENT/accounts.txt -Destination ./Tournament -Recurse
Copy-Item ./ETH_GO_CLIENT/contracts.txt -Destination ./Tournament -Recurse
Copy-Item ./ETH_GO_CLIENT/guid.blob -Destination ./Tournament -Recurse

# Push project into zip file (auto extension by PSh)
Add-Type -assembly "system.io.compression.filesystem"
# Package up all the images and the compose file for the project
$ZIP_FOLDER = "$($PWD.Path)/Tournament"
$ZIP_FILE = "$($PWD.Path)/Tournament.zip"
if(Test-Path $ZIP_FILE){
  Remove-Item -Path $ZIP_FILE
}
if([io.compression.zipfile]::CreateFromDirectory($ZIP_FOLDER, $ZIP_FILE)){
  Remove-Item -Recurse -Path ./Tournament
}

# Cleanup
foreach($PROJECT in $DOCKER_PROJECTS) {
# Alert and process
  echo "[INFO] -> (NOT) Cleaning up project: $PROJECT"

# Cleanup all built images
#  docker rmi -f tournament/${PROJECT}:latest
  ECHO ${NL}
}

# Clean up any intermediate/builder images
echo "[INFO] -> (NOT) Cleaning up intermediate docker images..."
# docker image prune -f
ECHO ${NL}
