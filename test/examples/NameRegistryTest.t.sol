/// SPDX-License-Identifier: MIT
/// @author 0xCooki
pragma solidity ^0.8.8;

import {ptr} from "src/DoublyLinkedList.sol";
import {NameRegistry} from "src/examples/NameRegistry.sol";
import {Test} from "forge-std/Test.sol";

contract NameRegistryTest is Test {
    NameRegistry public nameRegistry;

    function setUp() public {
        nameRegistry = new NameRegistry();
    }

    function testInit() public view {
        assertEq(nameRegistry.owner(), address(this));
        (uint64 counter, uint64 length, ptr head, ptr tail, uint64 version) = nameRegistry.list();
        assertEq(counter, 3);
        assertEq(length, 1);
        assertEq(ptr.unwrap(head), 2);
        assertEq(ptr.unwrap(tail), 2);
        assertEq(version, 0);
        bytes memory cooki = nameRegistry.valueAtPosition(0);
        assertEq(cooki, "Cooki");
    }

    function testPushTwoAndApendOneToBeginning() public {
        /// Push two
        nameRegistry.addValueAtPosition(1, "Sarah");
        nameRegistry.addValueAtPosition(1, "Billy");
        (uint64 counter, uint64 length, ptr head, ptr tail, uint64 version) = nameRegistry.list();
        assertEq(counter, 5);
        assertEq(length, 3);
        assertEq(ptr.unwrap(head), 2);
        assertEq(ptr.unwrap(tail), 4);
        assertEq(version, 0);
        bytes memory returned = nameRegistry.valueAtPosition(2);
        assertEq(returned, "Sarah");
        /// Add one to the front
        nameRegistry.addValueAtPosition(0, "Claire");
        (counter, length, head, tail, version) = nameRegistry.list();
        assertEq(counter, 6);
        assertEq(length, 4);
        assertEq(ptr.unwrap(head), 6);
        assertEq(ptr.unwrap(tail), 4);
        assertEq(version, 0);
        /// Cooki now in second position
        returned = nameRegistry.valueAtPosition(1);
        assertEq(returned, "Cooki");
    }

    function testPushTwoAndDeleteSecondNode() public {
        /// Push two to the beginning
        nameRegistry.addValueAtPosition(0, "Sarah");
        nameRegistry.addValueAtPosition(0, "Billy");
        (uint64 counter, uint64 length, ptr head, ptr tail, uint64 version) = nameRegistry.list();
        assertEq(counter, 5);
        assertEq(length, 3);
        assertEq(ptr.unwrap(head), 5);
        assertEq(ptr.unwrap(tail), 2);
        assertEq(version, 0);
        /// Delete sarah
        nameRegistry.removeValueAtPosition(1);
        (counter, length, head, tail, version) = nameRegistry.list();
        assertEq(counter, 5);
        assertEq(length, 2);
        assertEq(ptr.unwrap(head), 5);
        assertEq(ptr.unwrap(tail), 2);
        assertEq(version, 0);
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
