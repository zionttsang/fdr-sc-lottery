// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";

// import for Mocks on Anvil;
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        uint256 _entranceFee;
        uint256 _interval;
        address _vrfCoordinator;
        bytes32 _gasLane;
        uint64 _subscriptionId;
        uint32 _callbackGasLimit;
    }

    NetworkConfig public activeNetworkConfig;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
            // } else if (block.chainid == 1) {
            //     activeNetworkConfig = getMainnetEthChain();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthChain();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        return
            NetworkConfig({
                _entranceFee: 0.009 ether,
                _interval: 30,
                _vrfCoordinator: 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625,
                _gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
                _subscriptionId: 0,
                _callbackGasLimit: 500000
            });
    }

    function getOrCreateAnvilEthChain() public returns (NetworkConfig memory) {
        if (activeNetworkConfig._vrfCoordinator != address(0)) {
            return activeNetworkConfig;
        }

        // constructor params for V2Mock;
        uint96 baseFee = 0.25 ether;
        uint96 gasPriceLink = 1e9;

        vm.startBroadcast();
        VRFCoordinatorV2Mock vrfCoordinateMock = new VRFCoordinatorV2Mock(
            baseFee,
            gasPriceLink
        );
        vm.stopBroadcast();

        return
            NetworkConfig({
                _entranceFee: 0.007 ether,
                _interval: 30,
                _vrfCoordinator: address(vrfCoordinateMock),
                _gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
                _subscriptionId: 0,
                _callbackGasLimit: 500000
            });
    }
}
