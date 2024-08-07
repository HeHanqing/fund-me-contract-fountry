// SPDX-License-Identifier: MIT

//Deploy mocks when we are on a local anvil chain
//Kepp track of contract address across different chains
//Sepolia ETH/USD
//Mainnet ETH/USD

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script{
  //If we are on a local anvil, we deploy mocks
  //Otherwise, grab the existing address from the live network
  NetworkConfig public activeNetworkConfig;

  uint8 public constant DECIMAL = 8;
  int256 public constant INITIAL_PRICE = 2000e8;

  struct NetworkConfig {
    address priceFeed; //ETH/USD price feed address
  }

  constructor() {
    if(block.chainid == 11155111){
      activeNetworkConfig = getSepoliaEthConfig();
    }else{
      activeNetworkConfig = getOrCreateAnvilEthConfig();
    }
  }

  function getSepoliaEthConfig() public pure returns (NetworkConfig memory){
    //price feed address
    NetworkConfig memory sepoliaConfig = NetworkConfig({
      priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
    });
    return sepoliaConfig;
  }

  function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory){
    if(activeNetworkConfig.priceFeed != address(0)){
      return activeNetworkConfig;
    }

    vm.startBroadcast();
    MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMAL, INITIAL_PRICE);
    vm.stopBroadcast();

    NetworkConfig memory anvilConfig = NetworkConfig({priceFeed: address(mockPriceFeed)});
    return anvilConfig;
  }
}