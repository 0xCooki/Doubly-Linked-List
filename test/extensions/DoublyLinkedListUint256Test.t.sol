/// SPDX-License-Identifier: MIT
/// @author 0xCooki
pragma solidity ^0.8.8;

import {ptr} from "src/DoublyLinkedList.sol";
import {DoublyLinkedListUint256} from "src/extensions/DoublyLinkedListUint256.sol";
import {Test} from "forge-std/Test.sol";

contract MockDoublyLinkedListUint256 is DoublyLinkedListUint256 {
    function addValueAtPosition(uint64 _i, uint256 _value) public {
        _addValueAtPosition(_i, _value);
    }

    function amendValueAtPosition(uint64 _i, uint256 _value) public {
        _amendValueAtPosition(_i, _value);
    }

    function removeValueAtPosition(uint64 _i) public {
        _removeValueAtPosition(_i);
    }

    function push(uint256 _value) public {
        _push(_value);
    }

    function pop() public {
        _pop();
    }
}

contract DoublyLinkedListUint256Test is Test {
    MockDoublyLinkedListUint256 public dllUint256;

    function setUp() public {
        dllUint256 = new MockDoublyLinkedListUint256();
    }

    function testInit() public view {
        (uint64 counter, uint64 length, ptr head, ptr tail, uint64 version) = dllUint256.list();
        assertEq(counter, 0);
        assertEq(length, 0);
        assertEq(ptr.unwrap(head), 0);
        assertEq(ptr.unwrap(tail), 0);
        assertEq(dllUint256.length(), 0);
        assertEq(version, 0);
    }

    function testAddValueAtPosition(uint256 _value) public {
        vm.expectRevert();
        dllUint256.addValueAtPosition(1, _value);
        vm.expectRevert();
        dllUint256.valueAtPosition(0);
        /// Add at position zero
        dllUint256.addValueAtPosition(0, _value);
        (uint64 counter, uint64 length, ptr head, ptr tail, uint64 version) = dllUint256.list();
        assertEq(counter, 1);
        assertEq(length, 1);
        assertEq(ptr.unwrap(head), 1);
        assertEq(ptr.unwrap(tail), 1);
        assertEq(dllUint256.length(), 1);
        assertEq(dllUint256.valueAtPosition(0), _value);
        assertEq(version, 0);
        /// Add at position one
        dllUint256.addValueAtPosition(1, _value);
        (counter, length, head, tail, version) = dllUint256.list();
        assertEq(counter, 2);
        assertEq(length, 2);
        assertEq(ptr.unwrap(head), 1);
        assertEq(ptr.unwrap(tail), 2);
        assertEq(dllUint256.length(), 2);
        assertEq(dllUint256.valueAtPosition(1), _value);
        assertEq(version, 0);
    }

    function testAmendValueAtPosition(uint256 _value0, uint256 _value1) public {
        vm.expectRevert();
        dllUint256.amendValueAtPosition(0, _value0);
        dllUint256.push(_value0);
        assertEq(dllUint256.valueAtPosition(0), _value0);
        dllUint256.amendValueAtPosition(0, _value1);
        assertEq(dllUint256.valueAtPosition(0), _value1);
    }

    function testRemoveValueAtPosition(uint256 _value0, uint256 _value1) public {
        vm.expectRevert();
        dllUint256.removeValueAtPosition(0);
        dllUint256.push(_value0);
        dllUint256.push(_value0);
        dllUint256.push(_value1);
        (uint64 counter, uint64 length, ptr head, ptr tail, uint64 version) = dllUint256.list();
        assertEq(counter, 3);
        assertEq(length, 3);
        assertEq(ptr.unwrap(head), 1);
        assertEq(ptr.unwrap(tail), 3);
        assertEq(dllUint256.length(), 3);
        assertEq(dllUint256.valueAtPosition(0), _value0);
        assertEq(dllUint256.valueAtPosition(1), _value0);
        assertEq(dllUint256.valueAtPosition(2), _value1);
        assertEq(version, 0);
        /// Remove second value
        dllUint256.removeValueAtPosition(1);
        (counter, length, head, tail, version) = dllUint256.list();
        assertEq(counter, 3);
        assertEq(length, 2);
        assertEq(ptr.unwrap(head), 1);
        assertEq(ptr.unwrap(tail), 3);
        assertEq(dllUint256.length(), 2);
        assertEq(dllUint256.valueAtPosition(0), _value0);
        assertEq(dllUint256.valueAtPosition(1), _value1);
        assertEq(version, 0);
    }

    function testPop(uint256 _value) public {
        vm.expectRevert();
        dllUint256.pop();
        dllUint256.push(_value);
        dllUint256.pop();
        (uint64 counter, uint64 length, ptr head, ptr tail, uint64 version) = dllUint256.list();
        assertEq(counter, 1);
        assertEq(length, 0);
        assertEq(ptr.unwrap(head), 0);
        assertEq(ptr.unwrap(tail), 0);
        assertEq(dllUint256.length(), 0);
        assertEq(version, 0);
    }
}
