// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {ptr, Node, DLL, NodeLib, DoublyLinkedListLib, isValidPointer, validatePointer} from "src/DoublyLinkedList.sol";
import {Test, console} from "forge-std/Test.sol";

contract DoublyLinkedListTest is Test {
    using NodeLib for Node;
    using DoublyLinkedListLib for DLL;

    DLL public dll;

    struct Data {
        uint256 x;
    }

    function setUp() public {}

    function testEmptyList() public view {
        assertEq(dll.length, 0);
    }
}
