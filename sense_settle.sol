// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "hardhat/console.sol";

/**
 * @title SenseSeriesBot
 * Create and settle a Sense series
 */
contract SenseSeriesBot {

    address private owner;
    uint256 private maturity_time;
    address private adapter_address;

    // Contract addresses deployed by Sense Protocol
    address private divider_contract = 0x86bA3E96Be68563E41c2f5769F1AF9fAf758e6E0;
    address private periphery_contract = 0xFff11417a58781D3C72083CB45EF54d79Cd02437;


    
    // modifier to check if caller is owner
    modifier isOwner() {
        // If the first argument of 'require' evaluates to 'false', execution terminates and all
        // changes to the state and to Ether balances are reverted.
        // This used to consume all gas in old EVM versions, but not anymore.
        // It is often a good idea to use 'require' to check if functions are called correctly.
        // As a second argument, you can also provide an explanation about what went wrong.
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
    
    /**
     * @dev Set contract deployer as owner
     */
    constructor() {
        console.log("Owner contract deployed by:", msg.sender);
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
    }

    /**
     * @dev Deploy series
     * @param adapter address of the adpater used for Sense series
     * @param maturity time of series
     */
     function deploySenseSeries(address adapter, uint256 maturity) public isOwner {
         maturity_time = maturity;
         adapter_address = adapter;
         // Create Sense series given the adapter address and maturity time
         periphery_contract.delegatecall{gas: 1000000}(abi.encodeWithSignature("sponsorSeries(address,unit256)", adapter_address, maturity_time));
     }

    /**
     * @dev Settle deplolyed series
     */
     function settleSenseSeries() public isOwner {
         checkMaturity();
         // Create Sense series given the adapter address and maturity time
         divider_contract.delegatecall{gas: 1000}(abi.encodeWithSignature("settleSeries(address,unit256)", adapter_address, maturity_time));
     }

     function checkMaturity() private view {
         uint256 currTime = getCurrUnixTime();
         require(currTime >= maturity_time, "The series you're trying to settle hasn't matured yet!");
     }

     function getCurrUnixTime() private view returns (uint256) {
         return block.timestamp;
     }

    /**
     * @dev Return owner address 
     * @return address of owner
     */
    function getOwner() external view returns (address) {
        return owner;
    }

    /**
     * @dev Rturn time of series maturity
     * @return maturity time
     */
    function getMaturityTime() external view returns (uint256) {
        return maturity_time;
    }

    /**
     * @dev Return address of adapter
     * @return adapter address
     */
    function getAdapterAddress() external view returns (address) {
        return adapter_address;
    }
}
