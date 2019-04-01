
if(!$PSScriptRoot){ $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

foreach( $FOLDER in $(Get-ChildItem -dir | ForEach-Object { $_.Name.ToLower() }) ) {
  Remove-Variable GIT_COMMAND
  switch ($FOLDER){
    "apollo_booster" {
      $GIT_COMMAND="http://github.com/blockitrocket/apollo $FOLDER/apollo"
      break
    }
    "eth_go_client" {
      $GIT_COMMAND="https://github.com/ethereum/go-ethereum $FOLDER/geth"
      break
    }
    "eth_net_front" {
      $GIT_COMMAND="https://github.com/cubedro/eth-netstats $FOLDER/netstats"
      break
    }
    default {
      echo "Project has no git requirements to fulfill -$PROJECT"
    }
  }
  if(!GIT_COMMAND){
    Remove-Variable GIT_COMMAND
  } else {
    echo "Fetching git requirements to fulfill -$PROJECT"
    iex "git clone $GIT_COMMAND"
  }
  echo
}
