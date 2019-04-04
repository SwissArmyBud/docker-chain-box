
shScriptRoot=$( pwd )

for FOLDER in $(find ${shScriptRoot}/Projects -maxdepth 1 -mindepth 1 -type d)
do
  PROJECT=$(basename $FOLDER | tr '[:upper:]' '[:lower:]')
  unset GIT_COMMAND
  case $PROJECT in
    apollo_booster) GIT_COMMAND="http://github.com/blockitrocket/apollo $FOLDER/apollo"
    ;;
    eth_go_client) GIT_COMMAND="https://github.com/ethereum/go-ethereum $FOLDER/geth"
    ;;
    eth_net_front) GIT_COMMAND="https://github.com/cubedro/eth-netstats $FOLDER/netstats"
    ;;
    \?) echo "Project $PROJECT has no git requirements to fulfill..."
    ;;
  esac
  if [[ -v $GIT_COMMAND ]]; then
    echo  "Skipping..."
  else
    echo "Fetching git requirements to fulfill - $PROJECT"
    git clone $GIT_COMMAND
  fi
  echo
done


cd ${shScriptRoot}/Scripts/ChainJS
npm install
cd ${shScriptRoot}

chmod +x ${shScriptRoot}/ProjectBuilder.sh
