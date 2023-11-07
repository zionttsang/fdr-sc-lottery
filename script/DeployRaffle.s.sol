// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployRaffle is Script {
    function run() external returns (Raffle, HelperConfig) {
        //

        HelperConfig helperConfig = new HelperConfig();

        // get config decoded version;
        (
            uint256 entranceFee,
            uint256 intervale,
            address vrfCoordinatore,
            bytes32 gasLanee,
            uint64 subscriptionIde,
            uint32 callbackGasLimit
        ) = helperConfig.activeNetworkConfig();

        vm.startBroadcast();
        Raffle raffle = new Raffle(
            entranceFee,
            intervale,
            vrfCoordinatore,
            gasLanee,
            subscriptionIde,
            callbackGasLimit
        );
        vm.stopBroadcast();
        return (raffle, helperConfig);
    }
}
