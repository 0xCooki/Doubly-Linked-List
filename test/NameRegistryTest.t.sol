// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {ptr, Node, DLL, NodeLib, DoublyLinkedListLib, isValidPointer, validatePointer} from "src/DoublyLinkedList.sol";
import {NameRegistry} from "src/examples/NameRegistry.sol";
import {Test, console} from "forge-std/Test.sol";

contract NameRegistryTest is Test {
    using NodeLib for Node;
    using DoublyLinkedListLib for DLL;

    NameRegistry public nameRegistry;

    function setUp() public {
        nameRegistry = new NameRegistry();
    }

    function testInit() public view {
        (uint64 counter, uint64 length, ptr head, ptr tail) = nameRegistry.registry();
        assertEq(counter, 1);
        assertEq(length, 1);
        assertEq(ptr.unwrap(head), 1);
        assertEq(ptr.unwrap(tail), 1);

        string memory cooki = nameRegistry.nameAtPosition(0);
        assertEq(cooki, "Cooki");
    }

    function testPushTwoAndApendOneToBeginning() public {
        /// Push two
        nameRegistry.addNameAtPosition(1, "Sarah");
        nameRegistry.addNameAtPosition(1, "Billy");

        (uint64 counter, uint64 length, ptr head, ptr tail) = nameRegistry.registry();
        assertEq(counter, 3);
        assertEq(length, 3);
        assertEq(ptr.unwrap(head), 1);
        assertEq(ptr.unwrap(tail), 2);

        string memory returned = nameRegistry.nameAtPosition(2);
        assertEq(returned, "Sarah");

        /// Add one to the front
        nameRegistry.addNameAtPosition(0, "Claire");

        (counter, length, head, tail) = nameRegistry.registry();
        assertEq(counter, 4);
        assertEq(length, 4);
        assertEq(ptr.unwrap(head), 4);
        assertEq(ptr.unwrap(tail), 2);

        /// Cooki now in second position
        returned = nameRegistry.nameAtPosition(1);
        assertEq(returned, "Cooki");
    }

    function testPushTwoAndDeleteSecondNode() public {
        /// Push two to the beginning
        nameRegistry.addNameAtPosition(0, "Sarah");
        nameRegistry.addNameAtPosition(0, "Billy");

        (uint64 counter, uint64 length, ptr head, ptr tail) = nameRegistry.registry();
        assertEq(counter, 3);
        assertEq(length, 3);
        assertEq(ptr.unwrap(head), 3);
        assertEq(ptr.unwrap(tail), 1);

        /// Delete sarah
        nameRegistry.removeNameAtPosition(1);

        (counter, length, head, tail) = nameRegistry.registry();
        assertEq(counter, 3);
        assertEq(length, 2);
        assertEq(ptr.unwrap(head), 3);
        assertEq(ptr.unwrap(tail), 1);
    }
}
