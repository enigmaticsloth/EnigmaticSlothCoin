// Import the EnigmaticSlothCoin contract artifact
const EnigmaticSlothCoin = artifacts.require("EnigmaticSlothCoin");

// Export the function that handles the deployment process
module.exports = function (deployer, network, accounts) {
    // Assume the owner of the contract is the first account
    const initialOwner = accounts[0];
    // Assume the reward pool address is the second account
    const rewardPool = accounts[1];

    // Deploy the contract with the initial owner and reward pool addresses
    deployer.deploy(EnigmaticSlothCoin, initialOwner, rewardPool);
};
