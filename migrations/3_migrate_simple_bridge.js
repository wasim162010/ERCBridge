const SimpleERC20Bridge = artifacts.require("SimpleERC20Bridge");

const { deployProxy } = require('@openzeppelin/truffle-upgrades');

module.exports = async function (deployer) {

  await deployProxy(SimpleERC20Bridge, { deployer});
};


