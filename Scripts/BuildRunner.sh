
# Create build directory
rm -r -f ${shScriptRoot}/Tournament 2>/dev/null
mkdir ${shScriptRoot}/Tournament
mkdir ${shScriptRoot}/Tournament/images
mkdir ${shScriptRoot}/Tournament/scripts
mkdir ${shScriptRoot}/Tournament/electron

# Build and export images for each project
for PROJECT in $(find ${shScriptRoot}/Projects -maxdepth 1 -mindepth 1 -type d)
do
  # Alert and move into project
  echo "[INFO] -> Starting project: $PROJECT"
  cd $PROJECT
  echo

  # Build new image for stack
  PROJECT=$(echo $(basename $PROJECT) | tr '[:upper:]' '[:lower:]')
  BUILD_STRING="docker build -t tournament/${PROJECT}:latest ."
  ls ./DockerArgs 1>/dev/null 2>&1
  if [ $? -eq 0 ]; then
    for LINE in $(grep ".*" ./DockerArgs)
    do
      BUILD_STRING="$BUILD_STRING --build-arg $LINE"
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
  docker save -o ${shScriptRoot}/Tournament/images/${PROJECT}.zip tournament/${PROJECT}:latest
  echo
done

# Todo - Split this off into a project-manageable section for decoupling
# Currently the assumption is that ETH_GO_CLIENT is indeed being build/packed
# Move composer to build directory
cp ${shScriptRoot}/docker-compose.yaml ${shScriptRoot}/Tournament
# Move compose-time token loader to build
cp ${shScriptRoot}/Scripts/ComposeTokenLoader.sh ${shScriptRoot}/Tournament/scripts
# Move runners to build
cp ${shScriptRoot}/Scripts/ChainRunner.exe ${shScriptRoot}/Tournament
cp ${shScriptRoot}/Scripts/TournamentRunner.exe ${shScriptRoot}/Tournament
# Move chain to build
cp -r ${shScriptRoot}/Projects/ETH_GO_CLIENT/datadir ${shScriptRoot}/Tournament
# Move chain read-outs to build
cp ${shScriptRoot}/Projects/ETH_GO_CLIENT/accounts.txt ${shScriptRoot}/Tournament
cp ${shScriptRoot}/Projects/ETH_GO_CLIENT/contracts.txt ${shScriptRoot}/Tournament
cp ${shScriptRoot}/Projects/ETH_GO_CLIENT/guid.blob ${shScriptRoot}/Tournament
# Move electron build to build
cp -r ${shScriptRoot}/Scripts/Electron/* ${shScriptRoot}/Tournament/electron

# Push project into zip file
tar -zcf ${shScriptRoot}/Tournament.zip ${shScriptRoot}/Tournament
# rm -r -f ${shScriptRoot}/Tournament

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
