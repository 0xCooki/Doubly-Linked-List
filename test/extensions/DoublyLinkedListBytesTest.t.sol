/// SPDX-License-Identifier: MIT
/// @author 0xCooki
pragma solidity ^0.8.8;

import {ptr, Node, DLL, NodeLib, DoublyLinkedListLib, isValidPointer, validatePointer} from "src/DoublyLinkedList.sol";
import {DoublyLinkedListBytes} from "src/extensions/DoublyLinkedListBytes.sol";
import {Test, console} from "forge-std/Test.sol";

contract DoublyLinkedListBytesTest is Test {
    DoublyLinkedListBytes public dllBytes;

    function setUp() public {
        dllBytes = new DoublyLinkedListBytes();
    }

    function testInit() public view {
        (uint64 counter, uint64 length, ptr head, ptr tail) = dllBytes.list();
        assertEq(counter, 0);
        assertEq(length, 0);
        assertEq(ptr.unwrap(head), 0);
        assertEq(ptr.unwrap(tail), 0);
        assertEq(dllBytes.length(), 0);
    }

    function testAddValueAtPosition(bytes calldata _value) public {
        vm.expectRevert();
        dllBytes.addValueAtPosition(1, _value);
        vm.expectRevert();
        dllBytes.valueAtPosition(0);
        /// Add at position zero
        dllBytes.addValueAtPosition(0, _value);
        (uint64 counter, uint64 length, ptr head, ptr tail) = dllBytes.list();
        assertEq(counter, 1);
        assertEq(length, 1);
        assertEq(ptr.unwrap(head), 1);
        assertEq(ptr.unwrap(tail), 1);
        assertEq(dllBytes.length(), 1);
        assertEq(dllBytes.valueAtPosition(0), _value);
        /// Add at position one
        dllBytes.addValueAtPosition(1, _value);
        (counter, length, head, tail) = dllBytes.list();
        assertEq(counter, 2);
        assertEq(length, 2);
        assertEq(ptr.unwrap(head), 1);
        assertEq(ptr.unwrap(tail), 2);
        assertEq(dllBytes.length(), 2);
        assertEq(dllBytes.valueAtPosition(1), _value);
    }

    function testAmendValueAtPosition(bytes calldata _value0, bytes calldata _value1) public {
        vm.expectRevert();
        dllBytes.amendValueAtPosition(0, _value0);
        dllBytes.push(_value0);
        assertEq(dllBytes.valueAtPosition(0), _value0);
        dllBytes.amendValueAtPosition(0, _value1);
        assertEq(dllBytes.valueAtPosition(0), _value1);
    }

    function testRemoveValueAtPosition(bytes calldata _value0, bytes calldata _value1) public {
        vm.expectRevert();
        dllBytes.removeValueAtPosition(0);
        dllBytes.push(_value0);
        dllBytes.push(_value0);
        dllBytes.push(_value1);
        (uint64 counter, uint64 length, ptr head, ptr tail) = dllBytes.list();
        assertEq(counter, 3);
        assertEq(length, 3);
        assertEq(ptr.unwrap(head), 1);
        assertEq(ptr.unwrap(tail), 3);
        assertEq(dllBytes.length(), 3);
        assertEq(dllBytes.valueAtPosition(0), _value0);
        assertEq(dllBytes.valueAtPosition(1), _value0);
        assertEq(dllBytes.valueAtPosition(2), _value1);
        /// Remove second value
        dllBytes.removeValueAtPosition(1);
        (counter, length, head, tail) = dllBytes.list();
        assertEq(counter, 3);
        assertEq(length, 2);
        assertEq(ptr.unwrap(head), 1);
        assertEq(ptr.unwrap(tail), 3);
        assertEq(dllBytes.length(), 2);
        assertEq(dllBytes.valueAtPosition(0), _value0);
        assertEq(dllBytes.valueAtPosition(1), _value1);
    }

    function testPop(bytes calldata _value) public {
        vm.expectRevert();
        dllBytes.pop();
        dllBytes.push(_value);
        dllBytes.pop();
        (uint64 counter, uint64 length, ptr head, ptr tail) = dllBytes.list();
        assertEq(counter, 1);
        assertEq(length, 0);
        assertEq(ptr.unwrap(head), 0);
        assertEq(ptr.unwrap(tail), 0);
        assertEq(dllBytes.length(), 0);
    }
}
