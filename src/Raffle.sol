// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import {console} from "forge-std/Test.sol";

/**
 * @title simple raffle.
 * @author Zion
 * @notice this is for creatin a simple raffle smart contract.
 * @dev Implement Chainlink VRFv2
 */
contract Raffle is VRFConsumerBaseV2 {
    error Raffle__NotEnoughETHSent();
    error Raffle__FailedToSendBalanceToWinner();
    error Raffle__NotOpen();
    error Raffle__UpkeepNotSatisfied();

    // enum for storage different states of the contract;
    enum RaffleState {
        OPEN,
        CALCULATING
    }

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

    // set a record for last winner; maybe it's not necessary;
    address private s_lastWinner;

    // state control;
    RaffleState private s_raffleState;

    // build a event. for add logs for Contract; more gas saving then storage;
    event EnterRaffle(address indexed player);
    event PickedWinner(address indexed winner);

    constructor(
        uint256 _entranceFee,
        uint256 _interval,
        address _vrfCoordinator,
        bytes32 _gasLane,
        uint64 _subscriptionId,
        uint32 _callbackGasLimit
    ) VRFConsumerBaseV2(_vrfCoordinator) {
        i_entranceFee = _entranceFee;
        i_interval = _interval;
        s_lastTimestamp = block.timestamp;
        i_vrfCoordinator = VRFCoordinatorV2Interface(_vrfCoordinator);
        i_gasLane = _gasLane;
        i_subscriptionId = _subscriptionId;
        i_callbackGasLimit = _callbackGasLimit;
        s_raffleState = RaffleState.OPEN;
    }

    //set a ticket price for user enter threshold .
    function enterRaffle() public payable {
        //  require(msg.value>= i_entranceFee, 'Not enough ETH entrance fee sent.');
        // change to use revert error since it's more gas saving.
        if (msg.value < i_entranceFee) {
            console.log(
                "In enterRaffle; value / entrance fee: ",
                uint256(msg.value),
                " / ",
                uint256(i_entranceFee)
            );
            revert Raffle__NotEnoughETHSent();
        }

        // check if Raffle opened
        if (s_raffleState != RaffleState.OPEN) {
            revert Raffle__NotOpen();
        }

        s_listOfPlayers.push(payable(msg.sender));
        emit EnterRaffle(msg.sender);
    }

    // check if meet the Raffle start status with Upkeep;
    function checkUpkeep(
        bytes memory /*checkData*/
    )
        public
        view
        returns (bool bl_upKeepSatisfied, bytes memory /*performData*/)
    {
        bool bl_timeSatisfied = block.timestamp - s_lastTimestamp > i_interval;
        bool bl_isOpenStatus = s_raffleState == RaffleState.OPEN;
        bool bl_ethSatisfied = address(this).balance > 0;
        bool bl_hasPlayer = s_listOfPlayers.length > 0;
        bl_upKeepSatisfied = (bl_timeSatisfied &&
            bl_ethSatisfied &&
            bl_isOpenStatus &&
            bl_hasPlayer);

        return (bl_upKeepSatisfied, "0x0");
    }

    // function pickWinner() external {
    function performUpkeep(bytes calldata /* performData */) external {
        // // compare the time see if the time interval is met.
        // if ((block.timestamp - s_lastTimestamp) < i_interval) {
        //     revert();
        // }
        (bool bl_upkeep, ) = checkUpkeep("");
        if (!bl_upkeep) {
            revert Raffle__UpkeepNotSatisfied();
        }
        // while picking, Raffle should be in CALCULATING state;
        s_raffleState = RaffleState.CALCULATING;

        i_vrfCoordinator.requestRandomWords(
            i_gasLane, //gas line.
            i_subscriptionId,
            REQUEST_CONFIRMATION, // number of confirmations;
            i_callbackGasLimit,
            NUM_WORDS
        );
    }

    // get radom num back from Chainlink;
    // The second input param is the feedback rdm num from Chainlink;
    function fulfillRandomWords(
        uint256 /*_requestId*/,
        uint256[] memory _randomWords
    ) internal override {
        // use modulo to get index of the winner;
        uint256 indexOfWinner = _randomWords[0] % s_listOfPlayers.length;
        address payable winner = s_listOfPlayers[indexOfWinner];
        s_lastWinner = winner;
        // send the money to winner;
        (bool success, ) = winner.call{value: address(this).balance}("");
        if (!success) {
            // if award failed, have some error handling;
            revert Raffle__FailedToSendBalanceToWinner();
        }

        // after send reward, this round of Raffle is finished; change to open state;
        // meanwhile set all the other vars as what it should be;
        s_raffleState = RaffleState.OPEN;
        s_lastTimestamp = block.timestamp;
        s_listOfPlayers = new address payable[](0);

        // log it;
        emit PickedWinner(winner);
    }

    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }

    function getRaffleState() external view returns (RaffleState) {
        return s_raffleState;
    }

    function getPlayer(uint256 indexOfPlayer) external view returns (address) {
        return s_listOfPlayers[indexOfPlayer];
    }
}
