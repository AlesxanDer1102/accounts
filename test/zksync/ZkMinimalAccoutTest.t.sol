// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {ZkMinimalAccount} from "src/zksync/ZkMinimalAccount.sol";

contract ZkMinimalAccountTest is Test {
    ZkMinimalAccount minimalAccount;

    function SetUp() public {
        minimalAccount = new ZkMinimalAccount();
    }

    
}
