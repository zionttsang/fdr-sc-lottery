// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
 * @title simple raffle.
 * @author Zion
 * @notice this is for creatin a simple raffle smart contract.
 * @dev Implement Chainlink VRFv2
 */
contract Raffle {
    error Raffle__NotEnoughETHSent();

    uint256 private immutable i_entranceFee;

    constructor(uint256 entranceFee) {
        i_entranceFee = entranceFee;
    }

    //set a ticket price for user enter threshold .
    function enterRaffle() external payable {
        //  require(msg.value>= i_entranceFee, 'Not enough ETH entrance fee sent.');
        // change to use revert error since it's more gas saving.
        if (msg.value < i_entranceFee) {
            revert Raffle__NotEnoughETHSent();
        }
    }

    function pickWinner() returns () {}

    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }
}
