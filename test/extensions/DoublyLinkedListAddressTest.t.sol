/// SPDX-License-Identifier: MIT
/// @author 0xCooki
pragma solidity ^0.8.8;

import {ptr, Node, DLL, NodeLib, DoublyLinkedListLib, isValidPointer, validatePointer} from "src/DoublyLinkedList.sol";
import {DoublyLinkedListAddress} from "src/extensions/DoublyLinkedListAddress.sol";
import {Test, console} from "forge-std/Test.sol";

contract DoublyLinkedListAddressTest is Test {
    DoublyLinkedListAddress public dllAddress;

    function setUp() public {
        dllAddress = new DoublyLinkedListAddress();
    }

    function testInit() public view {
        (uint64 counter, uint64 length, ptr head, ptr tail) = dllAddress.list();
        assertEq(counter, 0);
        assertEq(length, 0);
        assertEq(ptr.unwrap(head), 0);
        assertEq(ptr.unwrap(tail), 0);
        assertEq(dllAddress.length(), 0);
    }

    function testAddValueAtPosition(address _value) public {
        vm.expectRevert();
        dllAddress.addValueAtPosition(1, _value);
        vm.expectRevert();
        dllAddress.valueAtPosition(0);
        /// Add at position zero
        dllAddress.addValueAtPosition(0, _value);
        (uint64 counter, uint64 length, ptr head, ptr tail) = dllAddress.list();
        assertEq(counter, 1);
        assertEq(length, 1);
        assertEq(ptr.unwrap(head), 1);
        assertEq(ptr.unwrap(tail), 1);
        assertEq(dllAddress.length(), 1);
        assertEq(dllAddress.valueAtPosition(0), _value);
        /// Add at position one
        dllAddress.addValueAtPosition(1, _value);
        (counter, length, head, tail) = dllAddress.list();
        assertEq(counter, 2);
        assertEq(length, 2);
        assertEq(ptr.unwrap(head), 1);
        assertEq(ptr.unwrap(tail), 2);
        assertEq(dllAddress.length(), 2);
        assertEq(dllAddress.valueAtPosition(1), _value);
    }

    function testAmendValueAtPosition(address _value0, address _value1) public {
        vm.expectRevert();
        dllAddress.amendValueAtPosition(0, _value0);
        dllAddress.push(_value0);
        assertEq(dllAddress.valueAtPosition(0), _value0);
        dllAddress.amendValueAtPosition(0, _value1);
        assertEq(dllAddress.valueAtPosition(0), _value1);
    }

    function testRemoveValueAtPosition(address _value0, address _value1) public {
        vm.expectRevert();
        dllAddress.removeValueAtPosition(0);
        dllAddress.push(_value0);
        dllAddress.push(_value0);
        dllAddress.push(_value1);
        (uint64 counter, uint64 length, ptr head, ptr tail) = dllAddress.list();
        assertEq(counter, 3);
        assertEq(length, 3);
        assertEq(ptr.unwrap(head), 1);
        assertEq(ptr.unwrap(tail), 3);
        assertEq(dllAddress.length(), 3);
        assertEq(dllAddress.valueAtPosition(0), _value0);
        assertEq(dllAddress.valueAtPosition(1), _value0);
        assertEq(dllAddress.valueAtPosition(2), _value1);
        /// Remove second value
        dllAddress.removeValueAtPosition(1);
        (counter, length, head, tail) = dllAddress.list();
        assertEq(counter, 3);
        assertEq(length, 2);
        assertEq(ptr.unwrap(head), 1);
        assertEq(ptr.unwrap(tail), 3);
        assertEq(dllAddress.length(), 2);
        assertEq(dllAddress.valueAtPosition(0), _value0);
        assertEq(dllAddress.valueAtPosition(1), _value1);
    }

    function testPop(address _value) public {
        vm.expectRevert();
        dllAddress.pop();
        dllAddress.push(_value);
        dllAddress.pop();
        (uint64 counter, uint64 length, ptr head, ptr tail) = dllAddress.list();
        assertEq(counter, 1);
        assertEq(length, 0);
        assertEq(ptr.unwrap(head), 0);
        assertEq(ptr.unwrap(tail), 0);
        assertEq(dllAddress.length(), 0);
    }
}