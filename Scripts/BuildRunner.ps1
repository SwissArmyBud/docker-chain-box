
ECHO $psScriptRoot

# Setup rigs
$NL="`r`n"
ECHO ${NL}

# Move into Projects folder
Set-Location -Path ${psScriptRoot}/Projects

# Grab current folder layout
$DOCKER_PROJECTS = Get-ChildItem -dir | ForEach-Object { $_.Name.ToLower() }
ECHO "Building the following projects: $DOCKER_PROJECTS"
ECHO ${NL}

# Create build directory
if(Test-Path ${psScriptRoot}/Tournament){
  Remove-Item -Recurse -Path ${psScriptRoot}/Tournament
}
if(Test-Path ${psScriptRoot}/Tournament.zip){
  Remove-Item ${psScriptRoot}/Tournament.zip
}
New-Item -ItemType directory -Path ./Tournament
New-Item -ItemType directory -Path ./Tournament/images
New-Item -ItemType directory -Path ./Tournament/scripts
New-Item -ItemType directory -Path ./Tournament/electron

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
  docker save -o ./Tournament/images/${PROJECT}.zip tournament/${PROJECT}:latest
  ECHO ${NL}
}

Set-Location -Path ${psScriptRoot}

# Todo - Split this off into a project-manageable section for decoupling
# Currently the assumption is that ETH_GO_CLIENT is indeed being build/packed
# Move composer to build directory
Copy-Item ${psScriptRoot}/docker-compose.yaml -Destination ${psScriptRoot}/Tournament
# Move compose-time token loader to build
Copy-Item ${psScriptRoot}/Scripts/ComposeTokenLoader.ps1 -Destination ${psScriptRoot}/Tournament/scripts
# Move electron build to build
Copy-Item ${psScriptRoot}/Scripts/Electron/* -Destination ${psScriptRoot}/Tournament/electron -Recurse
# Add docker handler script to electron directory
Copy-Item ${psScriptRoot}/Scripts/ChainRunner.ps1 -Destination ${psScriptRoot}/Tournament/electron -Recurse
# Move runners to build
Copy-Item ${psScriptRoot}/Scripts/ChainRunner.exe -Destination ${psScriptRoot}/Tournament
Copy-Item ${psScriptRoot}/Scripts/TournamentRunner.exe -Destination ${psScriptRoot}/Tournament
# Move chain to build
Copy-Item ${psScriptRoot}/Projects/ETH_GO_CLIENT/datadir -Destination ${psScriptRoot}/Tournament/datadir -Recurse
# Move chain read-outs to build
Copy-Item ${psScriptRoot}/Projects/ETH_GO_CLIENT/accounts.txt -Destination ${psScriptRoot}/Tournament -Recurse
Copy-Item ${psScriptRoot}/Projects/ETH_GO_CLIENT/contracts.txt -Destination ${psScriptRoot}/Tournament -Recurse
Copy-Item ${psScriptRoot}/Projects/ETH_GO_CLIENT/guid.blob -Destination ${psScriptRoot}/Tournament -Recurse

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
