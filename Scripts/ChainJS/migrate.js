// *************************
// Simple JS file for migrating contracts to a POA chain
// *************************

var child = require('child_process');
var fs = require("fs");
var net = require('net');
var Web3 = require('web3')
var web3;

var gethDir = process.cwd() + "/Projects/ETH_GO_CLIENT";

// Get the genesis file and see how many signers are included
var rocketship = JSON.parse(fs.readFileSync(gethDir + "/genesis.json"));
// Remove hex header (2), pre and post fix (64, 130) and divide into keys (40)
var signerCount = ( rocketship.extraData.length - ( 2 + 64 + 130) ) / 40;
console.log("[JS] -> There are " + signerCount + " signers in the genesis file...");

// Get access to keystore
var keystore = gethDir + "/datadir/keystore";
var signerList = [];
var ownerList = [];
fs.readdirSync(keystore).forEach( (file) => {
  if(file.indexOf("SIGNER") > -1) signerList.push(JSON.parse(fs.readFileSync(keystore + "/" + file)).address);
  if(file.indexOf("OWNER") > -1) ownerList.push(JSON.parse(fs.readFileSync(keystore + "/" + file)).address);
});

// Unlock all the accounts we need
var unlockDuration = 600;
var keyBlob = fs.readFileSync(gethDir + "/guid.blob").toString().trim();
var accountsKeyed = 0;
var unlockOwners = function(){
  ownerList.forEach( async (owner) => {
    console.log("");
    console.log("[JS] -> Trying to unlock: " + owner);
    var ok = await web3.eth.personal.unlockAccount("0x" + owner, keyBlob, 600);
    if(ok) {
      console.log("[JS] -> Unlocked: " + owner);
    }
    else console.log("[JS] -> Error while unlocking: " + owner);
    accountsKeyed++;
    // Start migrations once all owners have been keyed (attempted unlock)
    if(accountsKeyed = ownerList.length){
      // TODO - Gather/gauge error here and proceed
      // NOW - Just proceed since we should have one unlocked account
      console.log("");
      console.log("[JS] -> Starting migrations with owners unlocked...");
      contractMigrator();
    }
  });
}

// Called when migrations are finished being deployed
var migrationsFinished = function(){
  console.log("[JS] -> Finished with migrations...");
  processList.forEach( (process) => process.kill());
  // NOTE - This is the run-out area of the script currently,
  // use this to call the next chained function if needed
}

// *****************************
// ************************
// START SIGNER PROCESSES
// ***********************
// *****************************

var signerProcessCount = 0;
var signerCliqueCount = parseInt((signerCount/2) + 1);
var signerTimer;
// Start enough processes to reach quorum, then start unlocking owners
var signerProcessStarted = function(){
  signerProcessCount++;
  clearTimeout(signerTimer);
  signerTimer = setTimeout( () => {
    var ipcPath = ( process.platform === "win32" ) ?
                    '//./pipe/geth.ipc' :
                    gethDir + "/datadir/geth.ipc";
    web3 = new Web3(ipcPath, net);
    // TODO - Set up a block watcher and trigger on ex. block #5
    //        This would allow for parsed migrations as well
    setTimeout(unlockOwners, 2000);
  }, 2000);
};
var signerProcessExited = function(){
  signerProcessCount--;
  if(!signerProcessCount){
    console.log("[JS] -> All signers exited...");
    // Do other stuff here once all the signers are closed
    // signersExited = true;
  }
};

// Reporting functions for signer processes
var _stdout = function(data){ /* console.log(`[SUB OK] -> ${data}`); */};
var _stderr = function(data){ /* console.log(`[SUB ER] -> ${data}`); */};
var _psexit = function(data){ /* console.log(`[SUB XT] -> ${data}`); */
  signerProcessExited();
};

var processList = [];
// PoA Clique requires (n/2)+1 signers for functionality
var startSigners = function(){
  for(var i = 0; i < signerCliqueCount; i++){
    console.log("[JS] -> Spawning new Geth signer for PoA - Position #" + i);
    var datadir = gethDir + "/datadir";
    let childArgs = [ "--unlock", signerList[i],
                      "--etherbase", signerList[i],
                      "--password", gethDir + "/guid.blob",
                      "--mine",
                      "--targetgaslimit", "10000000"
                    ];
    if( i == 0 ){
      // Tasks when node is first signer (MASTER)
    } else {
      // Copy the data directory and remove the existing node key
      child.execSync(`cp -r ${datadir} ${datadir + 1}`);
      child.execSync(`rm ${datadir + 1}/geth/nodekey`);

      // Get the value of the master enode address
      let bootkey = fs.readFileSync(`${datadir}/geth/bootkey`);
      // Add first node as a bootnode for p2p
      childArgs = childArgs.concat(["--bootnodes", `enode://${bookey}@127.0.0.1:30303`]);

      // Turn off IPC for node
      childArgs.push("--ipcdisable");
      // Set a new listener (start at 30310 and increment by 2)
      childArgs = childArgs.concat(["--port", (30310 + (2*i)).toString() ]);

      // Add the index to the datadir
      datadir += i;
    }

    childArgs = childArgs.concat(["--datadir", datadir]);

    console.log("[JS] -> Starting signer with arguments:");
    console.log(childArgs);
    let signerProcess = child.spawn("geth", childArgs);
    signerProcess.stdout.on('data', _stdout);
    signerProcess.stderr.on('data', _stderr);
    signerProcess.on('close', _psexit);
    processList.push(signerProcess);
    signerProcessStarted();
  }
}

// *********************************
// ***************************
// START TRUFFLE MIGRATIONS
// ***************************
// *********************************

// MIGRATION VARIABLES
// TODO - turn this into a package name and run import/migrate from database
var contractList = process.argv[2]
var artifactCount;
var deploymentFinished = false;
var deploymentsFinished = 0;
// DO MIGRATIONS
var contractMigrator = async function() {
    var artifacts = {};
    contractList.split(",").forEach( (contract) => {
      console.log("[JS] -> Importing: " + contract);
      try {
        artifacts[contract] = JSON.parse(fs.readFileSync(process.cwd() + "/Scripts/ChainJS/build/contracts/" + contract + ".json"));
        console.log("[JS] -> Gathered contract artifacts...");
      } catch (e) {
        // Critical error if contracts can't be injected
        throw new Error(e);
      }
    });
    artifactCount = Object.keys(artifacts).length;

    console.log("");
    var contractOutput = "\n";
    for (let i = 0; i < artifactCount; i++){
      let contract = artifacts[ Object.keys(artifacts)[i] ];
      console.log("---------------");
      console.log("[DEPLOY] -> Deploying " + contract.contractName);
      contractOutput += contract.contractName + " - #" + (i+1);
      contractOutput += "\n";
      let web3Contract = new web3.eth.Contract( contract.abi );
      let receipt = await web3Contract.deploy({ data: contract.bytecode })
                                      .send({
                                        from: "0x" + ownerList[0],
                                        gasPrice: web3.utils.toHex(0),
                                        gas: web3.utils.toHex(9500000)
                                      }).on('transactionHash', (tx) => {
                                         console.log("[DEPLOY] -> Tx Hash: " + tx)
                                      }).catch(e => {
                                        // TODO - Remove all of this when Web3
                                        // is fixed for transaction receipts
                                        if(e.toString().indexOf("reverted by the EVM:") == -1){
                                          console.log("Critical error!");
                                          console.log(e);
                                          // Unknown error, return undefined
                                          return undefined;
                                        } else {
                                          var er = e.toString();
                                          try{
                                            er = JSON.parse(er.substr(er.indexOf("EVM:") + 4, er.indexOf("}") - 3).trim());
                                            if(er.status){
                                                console.log("[DEPLOY] -> Receipt ok...");
                                            } else { console.log("[DEPLOY] -> Receipt status not ok!"); }
                                          } catch (error) {
                                            console.log("[DEPLOY] -> WARNING - WEB3 REPORTS EVM ROLLBACK, BAD RECEIPT PARSE...");
                                            console.log(er);
                                            // Our error parsing has failed - no guaranteed state, return undefined
                                            return undefined;
                                          }
                                          return er;
                                        }
                                      });
      if(receipt){
        console.log("[DEPLOY] -> Deployed to: " + receipt.contractAddress);
        contractOutput += "@{address=" + receipt.contractAddress.substr(2) + "}";
        contractOutput += "\n\n";
      } else {
        console.log("[DEPLOY] -> Failed to deploy contract!");
      }
      console.log("");
      deploymentsFinished++;
      if(deploymentsFinished == artifactCount){
        fs.writeFileSync(gethDir + "/contracts.txt", contractOutput);
        setTimeout( () => { migrationsFinished(); }, 2500);
      }
    }
    console.log("[JS] -> All done with exec/migrate kicks...");
};


// *********************************
// ***************************
// RUN THE MIGRATIONS PROGRAM
// ***************************
// *********************************
if(contractList.length) startSigners();
else console.log("[DEPLOY] -> No contracts found to deploy... skipping.")
