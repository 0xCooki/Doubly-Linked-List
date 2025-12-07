/// SPDX-License-Identifier: MIT
/// @author 0xCooki
pragma solidity ^0.8.8;

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
        (uint64 version, uint64 length,,) = dllUint256.list();
        assertEq(version, 0);
        assertEq(length, 0);
        assertEq(dllUint256.length(), 0);
    }

    function testAddValueAtPosition(uint256 _value) public {
        vm.expectRevert();
        dllUint256.addValueAtPosition(1, _value);
        vm.expectRevert();
        dllUint256.valueAtPosition(0);
        /// Add at position zero
        dllUint256.addValueAtPosition(0, _value);
        (uint64 version, uint64 length,,) = dllUint256.list();
        assertEq(version, 0);
        assertEq(length, 1);
        assertEq(dllUint256.length(), 1);
        assertEq(dllUint256.valueAtPosition(0), _value);

        /// Add at position one
        dllUint256.addValueAtPosition(1, _value);
        (version, length,,) = dllUint256.list();
        assertEq(version, 0);
        assertEq(length, 2);
        assertEq(dllUint256.length(), 2);
        assertEq(dllUint256.valueAtPosition(1), _value);
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
        (uint64 version, uint64 length,,) = dllUint256.list();
        assertEq(version, 0);
        assertEq(length, 3);
        assertEq(dllUint256.length(), 3);
        assertEq(dllUint256.valueAtPosition(0), _value0);
        assertEq(dllUint256.valueAtPosition(1), _value0);
        assertEq(dllUint256.valueAtPosition(2), _value1);
        /// Remove second value
        dllUint256.removeValueAtPosition(1);
        (version, length,,) = dllUint256.list();
        assertEq(version, 0);
        assertEq(length, 2);
        assertEq(dllUint256.length(), 2);
        assertEq(dllUint256.valueAtPosition(0), _value0);
        assertEq(dllUint256.valueAtPosition(1), _value1);
    }

    function testPop(uint256 _value) public {
        vm.expectRevert();
        dllUint256.pop();
        dllUint256.push(_value);
        dllUint256.pop();
        (uint64 version, uint64 length,,) = dllUint256.list();
        assertEq(version, 0);
        assertEq(length, 0);
        assertEq(dllUint256.length(), 0);
    }
}
