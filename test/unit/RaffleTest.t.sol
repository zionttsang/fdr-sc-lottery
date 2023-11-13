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
        console.log("PLAYER address: ", playerRecorded);
        assert(playerRecorded == PLAYER);

        /**
         * 在Solidity编程语言中，raffle.enterRaffle{value: raffleEntranceFee}(); 这行代码表示一个合约函数调用，并且在调用合约函数时发送了一些以太币。这在调用需要支付以太币（ETH）的函数时非常常见。
         * value: raffleEntranceFee 是一个特殊的参数，它表示了发送给被调用函数的以太币的数量。其中，value 是Solidity语言中用于指定发送量的预留关键字，raffleEntranceFee 可以看做一个变量名，它的意思就是进入抽奖的费用。
         * 所以，这行代码的意思就是调用 raffle 合约的 enterRaffle 函数，并且在调用时付了等于 raffleEntranceFee 的以太币。
         */
    }
}
