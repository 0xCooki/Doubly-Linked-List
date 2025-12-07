/// SPDX-License-Identifier: MIT
/// @author 0xCooki
pragma solidity ^0.8.8;

import {DoublyLinkedListBytes} from "src/extensions/DoublyLinkedListBytes.sol";
import {Test} from "forge-std/Test.sol";

contract MockDoublyLinkedListBytes is DoublyLinkedListBytes {
    function addValueAtPosition(uint64 _i, bytes memory _value) public {
        _addValueAtPosition(_i, _value);
    }

    function amendValueAtPosition(uint64 _i, bytes memory _value) public {
        _amendValueAtPosition(_i, _value);
    }

    function removeValueAtPosition(uint64 _i) public {
        _removeValueAtPosition(_i);
    }

    function push(bytes memory _value) public {
        _push(_value);
    }

    function pop() public {
        _pop();
    }
}

contract DoublyLinkedListBytesTest is Test {
    MockDoublyLinkedListBytes public dllBytes;

    function setUp() public {
        dllBytes = new MockDoublyLinkedListBytes();
    }

    function testInit() public view {
        assertEq(dllBytes.length(), 0);
    }

    function testAddValueAtPosition(bytes calldata _value) public {
        vm.expectRevert();
        dllBytes.addValueAtPosition(1, _value);
        vm.expectRevert();
        dllBytes.valueAtPosition(0);
        /// Add at position zero
        dllBytes.addValueAtPosition(0, _value);
        assertEq(dllBytes.length(), 1);
        assertEq(dllBytes.valueAtPosition(0), _value);
        /// Add at position one
        dllBytes.addValueAtPosition(1, _value);
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
        assertEq(dllBytes.length(), 3);
        assertEq(dllBytes.valueAtPosition(0), _value0);
        assertEq(dllBytes.valueAtPosition(1), _value0);
        assertEq(dllBytes.valueAtPosition(2), _value1);
        /// Remove second value
        dllBytes.removeValueAtPosition(1);
        assertEq(dllBytes.length(), 2);
        assertEq(dllBytes.valueAtPosition(0), _value0);
        assertEq(dllBytes.valueAtPosition(1), _value1);
    }

    function testPop(bytes calldata _value) public {
        vm.expectRevert();
        dllBytes.pop();
        dllBytes.push(_value);
        dllBytes.pop();
        assertEq(dllBytes.length(), 0);
    }
}
