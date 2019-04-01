
shScriptRoot=$( cd $( dirname ${BASH_SOURCE[0]} ) >/dev/null 2>&1 && pwd )

for FOLDER in $(find ${shScriptRoot}/Projects -maxdepth 1 -mindepth 1 -type d)
do
  PROJECT=$(echo $(basename $FOLDER) | tr '[:upper:]' '[:lower:]')
  unset GIT_COMMAND
  case $PROJECT in
    apollo_booster) $GIT_COMMAND="http://github.com/blockitrocket/apollo $FOLDER/apollo"
    ;;
    eth_go_client) $GIT_COMMAND="https://github.com/ethereum/go-ethereum $FOLDER/geth"
    ;;
    eth_net_front) $GIT_COMMAND="https://github.com/cubedro/eth-netstats $FOLDER/netstats"
    ;;
    \?) echo "Project has no git requirements to fulfill -$PROJECT"
    ;;
  esac
  echo "Fetching git requirements to fulfill -$PROJECT"
  if [[ -v $GIT_COMMAND ]]; then
    unset GIT_COMMAND
  else
    git clone $GIT_COMMAND
  fi
  echo
done
