pragma solidity ^0.8.0;

// This contract is designed to freeze an amount of ether within the contract until a release block.
// per amount frozen and per blocks held, an erc20 token will be granted to the recipient address

import 

contract BlockFreeze{
    // The following will allow the tracking of balances of the stake reward token in ethereum
    mapping(address => uint256) public balances;
    
    //TODO: a mechanism that takes into account the block number upon deposit() and number of blocks to release
    
    // Function that takes amount ETH and block delta to calculate ERC20 token reward. Tokens come from
    // initial 1,000,000,000 pool for liquidity. 1 token = .1 eth staked per block frozen
    // _ethereum: ethereum frozen
    // blockDelta: Difference in block height from freeze to release
    function  calculateReward(uint256 _wei, uint256 blockDelta) private returns (uint256) {
        return 10 * 10**24 * _wei * blockDelta;
    }
    
    
    // Deposit function
    // Function that deposits an amount of ether, in wei, into the hold
    // Blocks: number of blocks to freeze
    // @precondition: blocks > 0
    // @precondition: _wei > 0
    // @postcondition: msg.sender balance -= _wei
    // @postcondition: balances[msg.sender] += _wei
    // @postcondition: msg.sender recieves erc20 token proportionate to blocks frozen and amount frozen
    function deposit(uint256 _blocks, uint256 _wei) public {
        //TODO
    }
    
    function release(uint256 _blocks, uint256 _wei){
        balances[msg.sender] = calculateReward();
    }
    
}