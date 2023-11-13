// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {DeployRaffle} from "../../script/DeployRaffle.s.sol";
import {Raffle} from "../../src/Raffle.sol";
import {Test, console} from "forge-std/Test.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {Vm} from "forge-std/Vm.sol";

contract RaffleTest is Test {
    Raffle public raffle;
    HelperConfig public helperConfig;

    uint64 subscriptionId;
    bytes32 gasLane;
    uint256 interval;
    uint256 raffleEntranceFee;
    uint32 callbackGasLimit;
    address vrfCoordinatorV2;

    address public PLAYER = makeAddr("player");
    uint256 public constant INIT_BLC = 30 ether;

    function setUp() external {
        DeployRaffle dpler = new DeployRaffle();
        (raffle, helperConfig) = dpler.run();
        vm.deal(PLAYER, INIT_BLC);
        // console.log(PLAYER.balance);

        (
            raffleEntranceFee,
            interval,
            vrfCoordinatorV2,
            gasLane,
            subscriptionId,
            callbackGasLimit
        ) = helperConfig.activeNetworkConfig();
    }

    function testIsRaffleInitWithOpenState() public view {
        assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN);
    }

    function testRaffleRevertWhenNotEnoughEntryFee() public {
        // arrange
        vm.prank(PLAYER);
        // act
        vm.expectRevert(Raffle.Raffle__NotEnoughETHSent.selector);
        //assert
        raffle.enterRaffle();
    }

    function testIfPlayerIntoTheArray() public {
        // Arrange
        vm.prank(PLAYER);
        // Act
        console.log(
            "In test; value / fee  ",
            PLAYER.balance,
            "/",
            raffleEntranceFee
        );
        raffle.enterRaffle{value: raffleEntranceFee}();
        // Assert
        address playerRecorded = raffle.getPlayer(0);
        assert(playerRecorded == PLAYER);
    }
}
