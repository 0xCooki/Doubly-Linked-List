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
        (uint64 version, uint64 length,,) = nameRegistry.list();
        assertEq(version, 0);
        assertEq(length, 1);
        assertEq(nameRegistry.valueAtPosition(0), "Cooki");
    }

    function testPushTwoAndApendOneToBeginning() public {
        /// Push two
        nameRegistry.addValueAtPosition(1, "Sarah");
        nameRegistry.addValueAtPosition(1, "Billy");
        (uint64 version, uint64 length,,) = nameRegistry.list();
        assertEq(version, 0);
        assertEq(length, 3);
        bytes memory returned = nameRegistry.valueAtPosition(2);
        assertEq(returned, "Sarah");
        /// Add one to the front
        nameRegistry.addValueAtPosition(0, "Claire");
        (version, length,,) = nameRegistry.list();
        assertEq(version, 0);
        assertEq(length, 4);
        /// Cooki now in second position
        returned = nameRegistry.valueAtPosition(1);
        assertEq(returned, "Cooki");
    }

    function testPushTwoAndDeleteSecondNode() public {
        /// Push two to the beginning
        nameRegistry.addValueAtPosition(0, "Sarah");
        nameRegistry.addValueAtPosition(0, "Billy");
        (uint64 version, uint64 length,,) = nameRegistry.list();
        assertEq(version, 0);
        assertEq(length, 3);
        /// Delete sarah
        nameRegistry.removeValueAtPosition(1);
        (version, length,,) = nameRegistry.list();
        assertEq(version, 0);
        assertEq(length, 2);
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
