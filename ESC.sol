// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract EnigmaticSlothCoin is ERC20, ERC20Burnable, Ownable, ReentrancyGuard {
    uint256 private constant INITIAL_SUPPLY = 1e9 * 1e18; // Initial token supply of 1 billion
    uint256 private constant TRANSACTION_FEE_PERCENT = 1; // 1% transaction fee

    mapping(address => uint256) public stakingBalance; // Maps user address to their staked balance
    mapping(address => bool) public isStaking; // Maps user address to their staking status
    mapping(address => uint256) public startTime; // Maps user address to the time they started staking
    mapping(address => uint256) public lastClaimedTime; // Maps user address to the time they last claimed rewards

    address public rewardPool; // Address of the reward pool

    constructor(address initialOwner, address _rewardPool) ERC20("EnigmaticSlothCoin", "ESC") Ownable(initialOwner) {
        _mint(initialOwner, INITIAL_SUPPLY); // Mint initial tokens to the contract deployer
        rewardPool = _rewardPool; // Set the reward pool address
    }

    // Allows users to claim daily rewards
    function claimDailyReward() public {
        require(balanceOf(msg.sender) >= 1000 * 1e18, "You must hold at least 1000 tokens to be eligible for rewards");
        require(block.timestamp >= lastClaimedTime[msg.sender] + 1 days, "You can only claim once a day");

        uint256 reward = balanceOf(msg.sender) * 10 / 1000000; // 0.001% of the user's balance
        require(balanceOf(rewardPool) >= reward, "Not enough tokens in the reward pool");
        _transfer(rewardPool, msg.sender, reward);
        lastClaimedTime[msg.sender] = block.timestamp;
    }

    // Allows users to claim staking rewards
    function claimStakingReward() external nonReentrant {
        require(isStaking[msg.sender], "You are not staking");
        uint256 reward = calculateStakingReward(msg.sender);
        require(reward > 0, "No reward available");
        require(balanceOf(rewardPool) >= reward, "Not enough tokens in the reward pool");
        _transfer(rewardPool, msg.sender, reward);
    }

    // Calculates staking rewards for a user
    function calculateStakingReward(address user) public view returns(uint256) {
        if (!isStaking[user]) return 0;
        uint256 stakingTime = block.timestamp - startTime[user];
        uint256 rewardRate = stakingBalance[user] < 1000 * 1e18 ? 5 : 20; // 0.0005% or 0.002% per day
        uint256 reward = stakingBalance[user] * rewardRate / 1000000 * stakingTime / 86400; // Reward calculation
        return reward;
    }

    // Allows the owner to set the reward pool address
    function setRewardPool(address _newRewardPool) external onlyOwner {
        require(_newRewardPool != address(0), "Reward pool cannot be zero address");
        rewardPool = _newRewardPool;
    }

    // Allows the owner to distribute tokens as airdrop to multiple recipients
    function airdrop(uint256 percentage, address[] memory recipients) external onlyOwner {
        require(percentage > 0 && percentage <= 100, "Percentage must be between 1 and 100");
        uint256 totalAirdropAmount = totalSupply() * percentage / 100; // Calculate total airdrop amount
        uint256 individualAmount = totalAirdropAmount / recipients.length; // Calculate individual airdrop amount
        require(balanceOf(rewardPool) >= totalAirdropAmount, "Not enough tokens in the reward pool");

        for (uint256 i = 0; i < recipients.length; i++) {
            _transfer(rewardPool, recipients[i], individualAmount); // Transfer tokens to each recipient
        }
    }
}
