/// SPDX-License-Identifier: MIT
/// @author 0xCooki
pragma solidity ^0.8.8;

import {ptr, Node, DLL, NodeLib, DoublyLinkedListLib, isValidPointer, validatePointer} from "src/DoublyLinkedList.sol";
import {NameRegistry, GatedNameRegistry} from "src/examples/NameRegistry.sol";
import {Test, console} from "forge-std/Test.sol";

contract NameRegistryTest is Test {
    NameRegistry public nameRegistry;

    function setUp() public {
        nameRegistry = new NameRegistry();
    }

    function testInit() public view {
        (uint64 counter, uint64 length, ptr head, ptr tail) = nameRegistry.list();
        assertEq(counter, 1);
        assertEq(length, 1);
        assertEq(ptr.unwrap(head), 1);
        assertEq(ptr.unwrap(tail), 1);
        bytes memory cooki = nameRegistry.valueAtPosition(0);
        assertEq(cooki, "Cooki");
    }

    function testPushTwoAndApendOneToBeginning() public {
        /// Push two
        nameRegistry.addValueAtPosition(1, "Sarah");
        nameRegistry.addValueAtPosition(1, "Billy");
        (uint64 counter, uint64 length, ptr head, ptr tail) = nameRegistry.list();
        assertEq(counter, 3);
        assertEq(length, 3);
        assertEq(ptr.unwrap(head), 1);
        assertEq(ptr.unwrap(tail), 2);
        bytes memory returned = nameRegistry.valueAtPosition(2);
        assertEq(returned, "Sarah");
        /// Add one to the front
        nameRegistry.addValueAtPosition(0, "Claire");
        (counter, length, head, tail) = nameRegistry.list();
        assertEq(counter, 4);
        assertEq(length, 4);
        assertEq(ptr.unwrap(head), 4);
        assertEq(ptr.unwrap(tail), 2);
        /// Cooki now in second position
        returned = nameRegistry.valueAtPosition(1);
        assertEq(returned, "Cooki");
    }

    function testPushTwoAndDeleteSecondNode() public {
        /// Push two to the beginning
        nameRegistry.addValueAtPosition(0, "Sarah");
        nameRegistry.addValueAtPosition(0, "Billy");
        (uint64 counter, uint64 length, ptr head, ptr tail) = nameRegistry.list();
        assertEq(counter, 3);
        assertEq(length, 3);
        assertEq(ptr.unwrap(head), 3);
        assertEq(ptr.unwrap(tail), 1);
        /// Delete sarah
        nameRegistry.removeValueAtPosition(1);
        (counter, length, head, tail) = nameRegistry.list();
        assertEq(counter, 3);
        assertEq(length, 2);
        assertEq(ptr.unwrap(head), 3);
        assertEq(ptr.unwrap(tail), 1);
    }
}

contract GatedNameRegistryTest is Test {
    GatedNameRegistry public gatedNameRegistry;

    function setUp() public {
        gatedNameRegistry = new GatedNameRegistry();
    }

    function testInit() public view {
        assertEq(gatedNameRegistry.owner(), address(this));
        (uint64 counter, uint64 length, ptr head, ptr tail) = gatedNameRegistry.list();
        assertEq(counter, 3);
        assertEq(length, 1);
        assertEq(ptr.unwrap(head), 2);
        assertEq(ptr.unwrap(tail), 2);
        bytes memory cooki = gatedNameRegistry.valueAtPosition(0);
        assertEq(cooki, "Cooki");
    }

    function testAccessControl(address _caller) public {
        vm.assume(_caller != address(this));
        vm.startPrank(_caller);
        vm.expectRevert();
        gatedNameRegistry.addValueAtPosition(0, "Sarah");
        vm.expectRevert();
        gatedNameRegistry.amendValueAtPosition(0, "Sarah");
        vm.expectRevert();
        gatedNameRegistry.removeValueAtPosition(0);
        vm.expectRevert();
        gatedNameRegistry.push("Sarah");
        vm.expectRevert();
        gatedNameRegistry.pop();
        vm.stopPrank();
    }
}
