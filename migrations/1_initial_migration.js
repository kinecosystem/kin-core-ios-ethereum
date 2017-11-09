let Migrations = artifacts.require('./Migrations.sol');
let BasicTokenMock = artifacts.require('../contracts/BasicTokenMock.sol');

module.exports = (deployer, network, accounts) => {
    deployer.deploy(Migrations);

    deployer.deploy(BasicTokenMock).then(async () => {
        console.log(`Token contract deployed at ${BasicTokenMock.address}`);

        let token = await BasicTokenMock.new();
        token.assign(accounts[0], 1000);
        console.log(`Assigned 1000 tokens to account ${accounts[0]} ...`);
    });
};
