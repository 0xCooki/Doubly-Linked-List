/// SPDX-License-Identifier: MIT
/// @author 0xCooki
pragma solidity ^0.8.8;

import {NameRegistry} from "src/examples/NameRegistry.sol";
import {Test} from "forge-std/Test.sol";

// forge test --match-contract NameRegistryTest -vvvv

contract NameRegistryTest is Test {
    NameRegistry public nameRegistry;

    function setUp() public {
        nameRegistry = new NameRegistry();
    }

    function testInit() public view {
        assertEq(nameRegistry.owner(), address(this));
        assertEq(nameRegistry.length(), 1);
        assertEq(nameRegistry.valueAtPosition(0), "Cooki");
    }

    function testPushTwoAndApendOneToBeginning() public {
        /// Push two
        nameRegistry.addValueAtPosition(1, "Sarah");
        nameRegistry.addValueAtPosition(1, "Billy");
        assertEq(nameRegistry.length(), 3);
        assertEq(nameRegistry.valueAtPosition(2), "Sarah");
        /// Add one to the front
        nameRegistry.addValueAtPosition(0, "Claire");
        assertEq(nameRegistry.length(), 4);
        /// Cooki now in second position
        assertEq(nameRegistry.valueAtPosition(1), "Cooki");
    }

    function testPushTwoAndDeleteSecondNode() public {
        /// Push two to the beginning
        nameRegistry.addValueAtPosition(0, "Sarah");
        nameRegistry.addValueAtPosition(0, "Billy");
        assertEq(nameRegistry.length(), 3);
        /// Delete sarah
        nameRegistry.removeValueAtPosition(1);
        assertEq(nameRegistry.length(), 2);
        assertEq(nameRegistry.valueAtPosition(0), "Billy");
        assertEq(nameRegistry.valueAtPosition(1), "Cooki");
    }

    function testAccessControl(address _caller) public {
        vm.assume(_caller != address(this));
        vm.startPrank(_caller);
        vm.expectRevert();
        nameRegistry.addValueAtPosition(0, "Sarah");
        vm.expectRevert();
        nameRegistry.amendValueAtPosition(0, "Sarah");
        vm.expectRevert();
        nameRegistry.removeValueAtPosition(0);
        vm.expectRevert();
        nameRegistry.push("Sarah");
        vm.expectRevert();
        nameRegistry.pop();
        vm.stopPrank();
    }
}
