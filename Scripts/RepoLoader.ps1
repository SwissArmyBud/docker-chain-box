
if(!$PSScriptRoot){ $PSScriptRoot = $(Get-Location | Select -expandproperty Path) }

foreach( $FOLDER in $(Get-ChildItem -dir "${PSScriptRoot}/Projects" | ForEach-Object { $_.Name.ToLower() }) ) {
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
      echo "Project $PROJECT has no git requirements to fulfill..."
    }
  }
  if(!GIT_COMMAND){
    echo "Skipping..."
  } else {
    echo "Fetching git requirements to fulfill - $PROJECT"
    iex "git clone $GIT_COMMAND"
  }
  echo
}
