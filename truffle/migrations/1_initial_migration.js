const assert = require('assert');
let Migrations = artifacts.require('../contracts/Migrations.sol');
let TestToken = artifacts.require('../contracts/BasicTokenMock.sol');

module.exports = (deployer, network, accounts) => {
    deployer.deploy(Migrations);
    deployer.deploy(TestToken).then(async() => {
        contract = await TestToken.deployed()
        console.log(`TestToken contract deployed at ${contract.address}`);

       // give tokens to the testing account
       let numTokens = 1000;
       let ok;
       for (let i = 0; i<10; i++) {
           ok = await contract.assign(accounts[i], web3.toWei(numTokens, "ether"));
           assert.ok(ok);
       }

       // check resulting balance
       let balanceWei = (await contract.balanceOf(accounts[0])).toNumber();
       assert.equal(web3.fromWei(balanceWei, "ether"), numTokens);
       console.log(`Assigned ${numTokens} tokens to account ${accounts[0]} ...`);
    });
};
