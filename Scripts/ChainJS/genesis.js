// *************************
// Simple JS file for creating POA genesis.json file
// *************************
var fs = require("fs");
var crypto = require('crypto');
var BN = require('bn.js');
var rocketship = JSON.parse(fs.readFileSync(__dirname + "/rocketship.json"));

var signerCount = process.argv[2];
var funderCount = process.argv[3];

var keystore = process.cwd() + "/ETH_GO_CLIENT/datadir/keystore";

var signerList = [];
var funderList = [];
fs.readdirSync(keystore).forEach((file)=>{
  if(file.indexOf("SIGNER") > -1) signerList.push(JSON.parse(fs.readFileSync(keystore + "/" + file)).address);
  if(file.indexOf("FUNDER") > -1) funderList.push(JSON.parse(fs.readFileSync(keystore + "/" + file)).address);
});

if(signerList.length == 0) throw new Error("Bad signer list length!");
if(signerList.length != signerCount) throw new Error("Bad signer list length!");
if(funderList.length == 0) throw new Error("Bad funder list length!");
if(funderList.length != funderCount) throw new Error("Bad funder list length!");

// 32*(zero)bytes for PoA signer prefix
var signerPrefix = "0x0000000000000000000000000000000000000000000000000000000000000000";
// 65*(zero)bytes for PoA signer postfix
var signerPostfix = "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
var signerExtraData = "" + signerPrefix;
signerList.forEach((signer) => {
  signerExtraData += signer;
});
signerExtraData += signerPostfix;
rocketship.extraData = signerExtraData;

// Set the (whole) units desired for the entire system's lifespan
var fundingAmount = "24000000";
fundingAmount = new BN(fundingAmount);
// Push (whole) units past the decimal point for the system
fundingAmount = fundingAmount.mul(new BN(18));
// Divide among the funders
fundingAmount = fundingAmount.div(new BN(funderList.length));
fundingAmount = fundingAmount.toString(16);
if(fundingAmount.length % 2) fundingAmount = "0" + fundingAmount;
funderList.forEach((funder)=>{
  console.log("[GEN] -> Funder " + funder.substring(funder.length - 4) + " has " + fundingAmount + " credits...");
  rocketship.alloc[funder] = {balance: "0x" + fundingAmount};
});
console.log("");
var jsonOutput = JSON.stringify(rocketship);
fs.writeFileSync(process.cwd() + "/ETH_GO_CLIENT/genesis.json", jsonOutput);
console.log("[GEN] -> Wrote out config with MD5: " + crypto.createHash('md5')
                                                  .update(jsonOutput)
                                                  .digest("hex"));
