pragma solidity ^0.8.0;

// This contract is designed to freeze an amount of ether within the contract until a release block.
// per amount frozen and per blocks held, an erc20 token will be granted to the recipient address


contract BlockFreeze{
    // The following will allow the tracking of balances of the unclaimed stake reward token in an erc20 token
    mapping(address => uint256) public rewardsAvailable;
    
    // The following tracks the amount deposited and frozen
    mapping(address => uint256) public accounts;
    
    // The following 2 mappings tract the block when the address had deposited the ether, and then when they are available
    mapping(address => uint256) public blockDeposited;
    mapping(address => uint256) public blockAvailable;
    
    // The following keeps track of the previous balance to record amount deposited
    uint256 private previousBalance;
    
    constructor(){
        previousBalance = 0;
    }

    // Deposit function
    // Function that deposits an amount of ether, in wei, into the hold
    // Blocks: number of blocks to freeze
    // @precondition: blocks > 0
    // @precondition: _wei > 0
    // @postcondition: msg.sender balance -= _wei
    // @postcondition: balances[msg.sender] += _wei
    // @return: amount deposited
    function deposit(uint256 _blocks) public payable {
        uint256 amount = address(this).balance - previousBalance;
        previousBalance = address(this).balance;
        blockDeposited[msg.sender] = block.number;
        blockAvailable[msg.sender] = blockDeposited[msg.sender] + _blocks;
        accounts[msg.sender] = amount;
        rewardsAvailable[msg.sender] = calculateReward(amount, _blocks);
    }
    
    // Withdrawal function
    // Checks if the freeze lock is released. If so, transfers balance to msg.sender
    function withdraw() public {
        require(checkLock());
        payable(msg.sender).transfer(accounts[msg.sender]);
        }
    
    // Lock Check function
    // Checks if the current block is block to release the ethereum deposited by the sender's wallet.
    // will be run as a check for the withdraw function
    // @precondition: accounts[msg.sender] exists
    function checkLock() private returns(bool){
        if(block.number >= blockAvailable[msg.sender]){
            return true;
        }
        return false;
    }
    
    // Upon successful withdrawal, sends erc20 token
    function sendRewards() private {
        //TODO: implement erc20 transfer
    }
    
    // Function that takes amount ETH and block delta to calculate ERC20 token reward. Tokens come from
    // initial 1,000,000,000 pool for liquidity. 1 token = .1 eth staked per block frozen
    // _ethereum: ethereum frozen
    // blockDelta: Difference in block height from freeze to release
    function  calculateReward(uint256 _wei, uint256 blockDelta) private returns (uint256) {
        return 10 * 10**24 * _wei * blockDelta;
    }
    
}
