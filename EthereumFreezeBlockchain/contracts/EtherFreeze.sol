//SPDX-License-Identifier: MIT"
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// This contract is designed to freeze an amount of ether within the contract until a release block.
// per amount frozen and per blocks held, an erc20 token will be granted to the recipient address

contract EtherFreeze is ERC20{

    // Variable to hold amount of wei per ether
    uint256 weiPerEther = 1000000000000000000;

    // Initial supply of Frost token
    uint256 initialSupply = 10**12;

    // Multiplier of the reward function
    uint rewardMultiplier = 100;

    /*
     *
     */
    constructor() ERC20("Frost", "FRST") public {
        _mint(address(this), initialSupply);
    }

    // The following will allow the tracking of balances of the unclaimed stake reward token in an erc20 token
    mapping(address => accountInfo) public accounts;
    
    /* Struct to consolidate account details
    *  rewardsAvailable: Rewards to be given upon withdrawal
    *  balance: balance of frozen ethereum
    *  blockDeposited: Record of block deposited
    *  blockAvailable: Record of block of release
    */
    struct accountInfo{
        uint256 rewardsAvailable;
        uint256 balance;
        uint256 blockDeposited;
        uint256 blockAvailable;
    }

    // Deposit function
    // Function that deposits the transacted ether into the hold
    // If the account has a non 0 balance, release the calculated reward to the user as an incentive, add the additional funds, and update lock date
    // Blocks: number of blocks to freeze
    // @precondition: blocks > 0
    // @postcondition: msg.sender balance -= _wei
    // @postcondition: balances[msg.sender] += _wei
    // @return: amount deposited
    function deposit(uint256 _blocks) public payable {
        if(_blocks <= 0){
            revert('Blocks frozen must be a positive integer');
        }
        if(accounts[msg.sender].balance == 0){
            uint256 amount = msg.value;
            accounts[msg.sender].blockDeposited = block.number;
            accounts[msg.sender].blockAvailable = block.number + _blocks;
            accounts[msg.sender].balance = amount;
            accounts[msg.sender].rewardsAvailable = calculateReward(accounts[msg.sender].balance, accounts[msg.sender].blockAvailable - accounts[msg.sender].blockDeposited);
        }
        else {
            sendRewards();
            accounts[msg.sender].blockDeposited = block.number;
            accounts[msg.sender].blockAvailable += _blocks;
            accounts[msg.sender].rewardsAvailable = calculateReward(accounts[msg.sender].balance, accounts[msg.sender].blockAvailable - accounts[msg.sender].blockDeposited);
        }
    }

    /* Withdrawal function
    * Checks if the freeze lock is released. If so, transfers balance to msg.sender, and sends available rewards
    */
    function withdraw() public {
        if(!checkLock()){
            revert('Lock has not yet released');
        }
        payable(msg.sender).transfer(accounts[msg.sender].balance);
        sendRewards();
        topUp();
        }
    

    /* Interface functions for struct mapping for user interface
     */
    function getAccountBalance() public view returns(uint256){
        return accounts[msg.sender].balance;
    }

    function getAccountDepositBlock() public view returns(uint256){
        return accounts[msg.sender].blockDeposited;
    }

    function getAccountAvailableBlock() public view returns(uint256){
        return accounts[msg.sender].blockAvailable;
    }

    function getAccountRewardsAvailable() public view returns(uint256){
        return accounts[msg.sender].rewardsAvailable;
    }
    
    // Lock Check function
    // Checks if the current block is block to release the ethereum deposited by the sender's wallet.
    // will be run as a check for the withdraw function
    // @precondition: accounts[msg.sender] exists
    function checkLock() private returns(bool){
        if(block.number >= accounts[msg.sender].blockAvailable){
            return true;
        }
        return false;
    }
    

    
    // Function that takes amount ETH and block delta to calculate ERC20 token reward. Tokens come from
    // initial 1,000,000,000 pool for liquidity. 1 token = .1 eth staked per block frozen
    // _ethereum: ethereum frozen
    // blockDelta: Difference in block height from freeze to release
    function  calculateReward(uint256 _wei, uint256 blockDelta) private returns (uint256) {
        return _wei * rewardMultiplier * blockDelta / weiPerEther ;
    }   
    
    // Upon successful withdrawal, sends erc20 token to msg.sender
    function sendRewards() private {
        //TODO: implement erc20 transfer
        transfer(msg.sender, accounts[msg.sender].rewardsAvailable);
    }

    // Top up function
    // checks if token reserve in contract wallet is less than 10^9.
    // if so, generates initialsupply - 10^9 tokens
    function topUp() private {
        if(this.balanceOf(address(this)) <= (initialSupply / 10**3)){
            _mint(address(this), (initialSupply - 10**9));
        }
    }

}