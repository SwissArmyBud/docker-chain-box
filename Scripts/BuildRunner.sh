
# Grab current folder layout
PROJECTS=""
for PROJECT in $(find ${shScriptRoot} -type d)
do
  PROJECTS="$PROJECTS $(echo $PROJECT | grep -Po "\./\K.*")"
done

DOCKER_PROJECTS=""
for FOLDER in $PROJECTS
do
  if [[ "$FOLDER" = "Tournaments" ]] || [[ "$FOLDER" = "Images" ]]; then
    # Ignore
  else
    DOCKER_PROJECTS="$DOCKER_PROJECTS $FOLDER"
  fi
done
echo "Building the following projects: $DOCKER_PROJECTS"
echo ${NL}

# Create build directory
rm -r -f ./Tournament 2>/dev/null
mkdir ./Tournament
mkdir ./Tournament/Images
mkdir ./Tournament/Scripts

# Build and export images for each project
for PROJECT in $DOCKER_PROJECTS
do
  # Alert and move into project
  echo "[INFO] -> Starting project: $PROJECT"
  cd ${shScriptRoot}/$PROJECT
  echo

  # Build new image for stack
  $BUILD_STRING = "docker build -t tournament/${PROJECT}:latest ."
  ls ./DockerArgs 1>/dev/null 2>&1
  if [ $? -ne 0 ]; then
    for LINE in $(grep ".*" ./DockerArgs)
    do
      $BUILD_STRING = "$BUILD_STRING --build-arg $LINE"
    done
  fi
  echo "[INFO] -> Starting docker build for: $PROJECT"
  echo $BUILD_STRING
  ${BUILD_STRING}
  echo

  # Leave project
  echo "[INFO] -> Finished tasks for: $PROJECT"
  cd ../
  echo

  # Output the image for stack
  echo "[INFO] -> Starting image export for: $PROJECT"
  docker save -o ./Tournament/Images/${PROJECT}.zip tournament/${PROJECT}:latest
  echo
done

# Todo - Split this off into a project-manageable section for decoupling
# Currently the assumption is that ETH_GO_CLIENT is indeed being build/packed
# Move composer to build directory
cp ${shScriptRoot}/docker-compose.yaml ${shScriptRoot}/Tournament
# Move compose-time token loader to build
cp ${shScriptRoot}/Scripts/ComposeTokenLoader.ps1 ${shScriptRoot}/Tournament/Scripts/
# Move runner to build
cp ${shScriptRoot}/Scripts/ProjectRunner.ps1 ${shScriptRoot}/Tournament
# Move chain to build
cp ${shScriptRoot}/ETH_GO_CLIENT/datadir ${shScriptRoot}/Tournament
# Move chain read-outs to build
cp ${shScriptRoot}/ETH_GO_CLIENT/accounts.txt ${shScriptRoot}/Tournament
cp ${shScriptRoot}/ETH_GO_CLIENT/contracts.txt ${shScriptRoot}/Tournament
cp ${shScriptRoot}/ETH_GO_CLIENT/guid.blob ${shScriptRoot}/Tournament

# Push project into zip file
tar -zcf ${shScriptRoot}/Tournament.zip ${shScriptRoot}/Tournament
rm -r -f ${shScriptRoot}/Tournament

# Alert and process
echo "[INFO] -> (NOT) Cleaning up project: $PROJECT"
for PROJECT in $DOCKER_PROJECTS
do
  # Cleanup all built images
  # docker rmi -f tournament/${PROJECT}:latest
  echo
done

# Clean up any intermediate/builder images
echo "[INFO] -> (NOT) Cleaning up intermediate docker images..."
# docker image prune -f
echo
