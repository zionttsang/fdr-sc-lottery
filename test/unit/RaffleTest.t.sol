// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {DeployRaffle} from "../../script/DeployRaffle.s.sol";
import {Raffle} from "../../src/Raffle.sol";
import {Test, console} from "forge-std/Test.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract RaffleTest is Test {
    Raffle raffle;
    HelperConfig helperConfig;

    DeployRaffle dpler = new DeployRaffle();

    address public PLAYER = makeAddr("player");
    uint256 public constant INIT_BLC = 10 ether;

    function setUp() external {
        (raffle, helperConfig) = dpler.run();

        (
            uint256 entranceFee,
            uint256 intervale,
            address vrfCoordinatore,
            bytes32 gasLanee,
            uint64 subscriptionIde,
            uint32 callbackGasLimit
        ) = helperConfig.activeNetworkConfig();
    }

    function testIsRaffleInitWithOpenState() public view {
        assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN);
    }
}
