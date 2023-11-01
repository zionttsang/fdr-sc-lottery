// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

/**
 * @title simple raffle.
 * @author Zion
 * @notice this is for creatin a simple raffle smart contract.
 * @dev Implement Chainlink VRFv2
 */
contract Raffle {
    error Raffle__NotEnoughETHSent();

    uint16 private constant REQUEST_CONFIRMATION = 3;
    uint32 private constant NUM_WORDS = 3;
    // entrance fee;
    uint256 private immutable i_entranceFee;
    // duration of the game in seconds.
    uint256 private immutable i_interval;
    // last time the game triggered; this will be compared to current timestamp and see if it's bigger than above interval;
    uint256 private s_lastTimestamp;
    // vrfCoordinator stuffs;
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    bytes32 private immutable i_gasLane;
    uint64 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;

    // add a payable array for storafe joiners. must payable if want to pay the winner in the end.
    address payable[] private s_listOfPlayers;

    // build a event. more gas saving.
    event EnterRaffle(address sender);

    constructor(
        uint256 _entranceFee,
        uint256 _interval,
        address _vrfCoordinator,
        bytes32 _gasLane,
        uint64 _subscriptionId,
        uint32 _callbackGasLimit
    ) {
        i_entranceFee = _entranceFee;
        i_interval = _interval;
        s_lastTimestamp = block.timestamp;
        i_vrfCoordinator = VRFCoordinatorV2Interface(_vrfCoordinator);
        i_gasLane = _gasLane;
        i_subscriptionId = _subscriptionId;
        i_callbackGasLimit = _callbackGasLimit;
    }

    //set a ticket price for user enter threshold .
    function enterRaffle() external payable {
        //  require(msg.value>= i_entranceFee, 'Not enough ETH entrance fee sent.');
        // change to use revert error since it's more gas saving.
        if (msg.value < i_entranceFee) {
            revert Raffle__NotEnoughETHSent();
        }

        s_listOfPlayers.push(payable(msg.sender));
        emit EnterRaffle(msg.sender);
    }

    function pickWinner() external {
        // compare the time see if the time interval is met.
        if ((block.timestamp - s_lastTimestamp) < i_interval) {
            revert();
        }

        uint256 requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane, //gas line.
            i_subscriptionId,
            REQUEST_CONFIRMATION, // number of confirmations;
            i_callbackGasLimit,
            NUM_WORDS
        );
    }

    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }
}
