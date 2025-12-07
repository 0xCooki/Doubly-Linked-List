/// SPDX-License-Identifier: MIT
/// @author 0xCooki
pragma solidity ^0.8.8;

import {DoublyLinkedListAddress} from "src/extensions/DoublyLinkedListAddress.sol";
import {Test} from "forge-std/Test.sol";

contract MockDoublyLinkedListAddress is DoublyLinkedListAddress {
    function addValueAtPosition(uint64 _i, address _value) public {
        _addValueAtPosition(_i, _value);
    }

    function amendValueAtPosition(uint64 _i, address _value) public {
        _amendValueAtPosition(_i, _value);
    }

    function removeValueAtPosition(uint64 _i) public {
        _removeValueAtPosition(_i);
    }

    function push(address _value) public {
        _push(_value);
    }

    function pop() public {
        _pop();
    }
}

contract DoublyLinkedListAddressTest is Test {
    MockDoublyLinkedListAddress public dllAddress;

    function setUp() public {
        dllAddress = new MockDoublyLinkedListAddress();
    }

    function testInit() public view {
        (uint64 version, uint64 length,,) = dllAddress.list();
        assertEq(version, 0);
        assertEq(length, 0);
        assertEq(dllAddress.length(), 0);
    }

    function testAddValueAtPosition(address _value) public {
        vm.expectRevert();
        dllAddress.addValueAtPosition(1, _value);
        vm.expectRevert();
        dllAddress.valueAtPosition(0);
        /// Add at position zero
        dllAddress.addValueAtPosition(0, _value);
        (uint64 version, uint64 length,,) = dllAddress.list();
        assertEq(version, 0);
        assertEq(length, 1);
        assertEq(dllAddress.length(), 1);
        assertEq(dllAddress.valueAtPosition(0), _value);
        /// Add at position one
        dllAddress.addValueAtPosition(1, _value);
        (version, length,,) = dllAddress.list();
        assertEq(version, 0);
        assertEq(length, 2);
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
        (uint64 version, uint64 length,,) = dllAddress.list();
        assertEq(version, 0);
        assertEq(length, 3);
        assertEq(dllAddress.length(), 3);
        assertEq(dllAddress.valueAtPosition(0), _value0);
        assertEq(dllAddress.valueAtPosition(1), _value0);
        assertEq(dllAddress.valueAtPosition(2), _value1);
        /// Remove second value
        dllAddress.removeValueAtPosition(1);
        (version, length,,) = dllAddress.list();
        assertEq(version, 0);
        assertEq(length, 2);
        assertEq(dllAddress.length(), 2);
        assertEq(dllAddress.valueAtPosition(0), _value0);
        assertEq(dllAddress.valueAtPosition(1), _value1);
    }

    function testPop(address _value) public {
        vm.expectRevert();
        dllAddress.pop();
        dllAddress.push(_value);
        dllAddress.pop();
        (uint64 version, uint64 length,,) = dllAddress.list();
        assertEq(version, 0);
        assertEq(length, 0);
        assertEq(dllAddress.length(), 0);
    }
}
