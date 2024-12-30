// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {ptr, Node, DLL, NodeLib, DoublyLinkedListLib, isValidPointer, validatePointer} from "src/DoublyLinkedList.sol";
import {NameRegistry, Name} from "src/examples/NameRegistry.sol";
import {Test, console} from "forge-std/Test.sol";

contract NameRegistryTest is Test {
    using NodeLib for Node;
    using DoublyLinkedListLib for DLL;

    NameRegistry public nameRegistry;

    function setUp() public {
        nameRegistry = new NameRegistry();
    }

    function testInit() public view {
        (uint256 length, uint256 counter, ptr head, ptr tail) = nameRegistry.registry();
        assertEq(length, 1);
        assertEq(counter, 1);
        assertEq(ptr.unwrap(head), 1);
        assertEq(ptr.unwrap(tail), 1);

        Name memory cooki = nameRegistry.nameAtPosition(0);
        assertEq(cooki.first, "Cooki");
        assertEq(cooki.middle, "Von");
        assertEq(cooki.last, "Crumble");
    }

    function testPushTwoAndApendOneToBeginning() public {
        /// Push two to the end
        Name memory sarah = Name({
            first: "Sarah",
            middle: "Jane",
            last: "Brown"
        });
        Name memory billy = Name({
            first: "Billy",
            middle: "John",
            last: "Blue"
        });

        nameRegistry.addNameAtPosition(1, sarah);
        nameRegistry.addNameAtPosition(2, billy);

        (uint256 length, uint256 counter, ptr head, ptr tail) = nameRegistry.registry();
        assertEq(length, 3);
        assertEq(counter, 3);
        assertEq(ptr.unwrap(head), 1);
        assertEq(ptr.unwrap(tail), 3);

        Name memory returned = nameRegistry.nameAtPosition(1);
        assertEq(returned.first, "Sarah");
        assertEq(returned.middle, "Jane");
        assertEq(returned.last, "Brown");

        /// Add one to the front
        Name memory claire = Name({
            first: "Claire",
            middle: "Joan",
            last: "Black"
        });

        nameRegistry.addNameAtPosition(0, claire);

        /// Cooki now in second position
        returned = nameRegistry.nameAtPosition(1);
        assertEq(returned.first, "Cooki");
        assertEq(returned.middle, "Von");
        assertEq(returned.last, "Crumble");
    }
}
