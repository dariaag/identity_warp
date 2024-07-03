// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {WarpIdentity} from "../src/WarpIdentity.sol";

contract WarpIdentityScript is Script {
    function setUp() public {}

    function run() public returns (WarpIdentity) {
        vm.startBroadcast();
        WarpIdentity warpIdentity = new WarpIdentity(
            0x46f7C5D896bbeC89bE1B19e4485e59b4Be49e9Cc
        );
        vm.stopBroadcast();
        return warpIdentity;
    }
}
