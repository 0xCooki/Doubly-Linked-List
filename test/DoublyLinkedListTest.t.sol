/// SPDX-License-Identifier: MIT
/// @author 0xCooki
pragma solidity ^0.8.8;

import {
    ptr,
    Node,
    DLL,
    NULL_PTR,
    InvalidPointer,
    InvalidLength,
    InvalidNode,
    ListEmpty,
    createPointer,
    isValidPointer,
    validatePointer,
    NodeLib,
    DoublyLinkedListLib
} from "src/DoublyLinkedList.sol";
import {Test, StdStorage, stdStorage} from "forge-std/Test.sol";

contract PtrTest is Test {
    function testCreatePointer(uint64 _seed) public pure {
        vm.assume(_seed != 0);
        ptr newPtr = createPointer(_seed);
        assertEq(ptr.unwrap(newPtr), _seed);
    }

    function testIsValidPointer(uint64 _seed) public pure {
        vm.assume(_seed != 0);
        ptr newPtr = createPointer(_seed);
        assertEq(isValidPointer(newPtr), true);
        assertEq(isValidPointer(NULL_PTR), false);
    }

    function testValidatePointer(uint64 _seed) public {
        vm.assume(_seed != 0);
        ptr newPtr = createPointer(_seed);
        validatePointer(newPtr);
        vm.expectRevert(InvalidPointer.selector);
        validatePointer(NULL_PTR);
    }
}

contract NodeTest is Test {
    using NodeLib for Node;

    Node public node;

    function testNewNode() public view {
        assertEq(isValidPointer(node.value), false);
        assertEq(isValidPointer(node.next), false);
        assertEq(isValidPointer(node.prev), false);
        assertEq(node.v, 0);
    }

    function testIsValidNode(uint64 _seed) public {
        vm.assume(_seed != 0);
        assertEq(node.isValidNode(_seed), false);
        node.value = ptr.wrap(_seed);
        assertEq(node.isValidNode(_seed), false);
        assertEq(node.isValidNode(node.v), true);
    }

    function testValidateNode(uint64 _seed) public {
        vm.assume(_seed != 0);
        vm.expectRevert(InvalidNode.selector);
        node.validateNode(node.v);
        node.value = ptr.wrap(_seed);
        vm.expectRevert(InvalidNode.selector);
        node.validateNode(_seed);
    }

    function testSet(uint64 _seed) public {
        vm.assume(_seed != 0);
        ptr newPtr = createPointer(_seed);
        node.set(newPtr, newPtr, newPtr, ptr.unwrap(newPtr));
        assertEq(isValidPointer(node.value), true);
        assertEq(isValidPointer(node.next), true);
        assertEq(isValidPointer(node.prev), true);
        assertEq(ptr.unwrap(node.value), _seed);
        assertEq(ptr.unwrap(node.next), _seed);
        assertEq(ptr.unwrap(node.prev), _seed);
    }

    function testClear(uint64 _seed) public {
        vm.assume(_seed != 0);
        ptr newPtr = createPointer(_seed);
        node.set(newPtr, newPtr, newPtr, ptr.unwrap(newPtr));
        node.clear();
        assertEq(isValidPointer(node.value), false);
        assertEq(isValidPointer(node.next), false);
        assertEq(isValidPointer(node.prev), false);
        assertEq(ptr.unwrap(node.value), 0);
        assertEq(ptr.unwrap(node.next), 0);
        assertEq(ptr.unwrap(node.prev), 0);
    }
}

contract DLLTestHelpers {
    uint64 public increment;

    function onEachIncrementAndStopAtOne(ptr, uint64 _i, bytes memory) internal returns (bool) {
        increment++;
        return (_i != 1);
    }

    function isMatchPtr(ptr _ptr, uint64, bytes memory _data) internal pure returns (bool) {
        return ptr.unwrap(_ptr) == abi.decode(_data, (uint64));
    }

    function isMatchIndex(ptr, uint64 _i, bytes memory _data) internal pure returns (bool) {
        return _i == abi.decode(_data, (uint64));
    }
}

contract DoublyLinkedListTest is Test, DLLTestHelpers {
    using DoublyLinkedListLib for DLL;
    using stdStorage for StdStorage;

    DLL public list;

    function testNewList() public view {
        assertEq(list.version, 0);
        assertEq(list.length, 0);
        assertEq(isValidPointer(list.head), false);
        assertEq(isValidPointer(list.tail), false);
    }

    function testStoragePacking() public {
        list.version = 0x1111111111111111;
        list.length = 0x2222222222222222;
        list.head = ptr.wrap(0x3333333333333333);
        list.tail = ptr.wrap(0x4444444444444444);
        uint256 slotNumber = stdstore.enable_packed_slots().target(address(this)).sig("list()").depth(0).find();
        bytes32 slot = vm.load(address(this), bytes32(slotNumber));
        assertEq(uint64(uint256(slot)), 0x1111111111111111, "version");
        assertEq(uint64(uint256(slot) >> 64), 0x2222222222222222, "length");
        assertEq(uint64(uint256(slot) >> 128), 0x3333333333333333, "head");
        assertEq(uint64(uint256(slot) >> 192), 0x4444444444444444, "tail");
    }

    function testValueAt(uint64 _seed) public {
        vm.assume(_seed != 0);
        ptr newValuePtr = createPointer(_seed);
        ptr nodePtr = list.push(newValuePtr);
        assertEq(ptr.unwrap(list.valueAt(nodePtr)), ptr.unwrap(newValuePtr));
    }

    function testNextAt(uint64 _seed) public {
        vm.assume(_seed != 0);
        ptr newValuePtr = createPointer(_seed);
        list.push(newValuePtr);
        ptr nodePtr = createPointer(1);
        assertEq(ptr.unwrap(list.nextAt(nodePtr)), 0);
    }

    function testPrevAt(uint64 _seed) public {
        vm.assume(_seed != 0);
        ptr newValuePtr = createPointer(_seed);
        list.push(newValuePtr);
        ptr nodePtr = createPointer(1);
        assertEq(ptr.unwrap(list.prevAt(nodePtr)), 0);
    }

    function testAt(uint64 _seed) public {
        vm.assume(_seed != 0);
        vm.assume(_seed < ~uint64(0) - 4);
        ptr nodePtr_0 = list.push(createPointer(_seed++));
        ptr nodePtr_1 = list.push(createPointer(_seed++));
        ptr nodePtr_2 = list.push(createPointer(_seed++));
        ptr nodePtr_3 = list.push(createPointer(_seed++));
        ptr nodePtr_4 = list.push(createPointer(_seed++));
        assertEq(ptr.unwrap(list.at(0)), ptr.unwrap(nodePtr_0));
        assertEq(ptr.unwrap(list.at(1)), ptr.unwrap(nodePtr_1));
        assertEq(ptr.unwrap(list.at(2)), ptr.unwrap(nodePtr_2));
        assertEq(ptr.unwrap(list.at(3)), ptr.unwrap(nodePtr_3));
        assertEq(ptr.unwrap(list.at(4)), ptr.unwrap(nodePtr_4));
        vm.expectRevert(InvalidLength.selector);
        list.at(5);
    }

    function testFind(uint64 _seed) external {
        vm.assume(_seed != 0);
        vm.assume(_seed < ~uint64(0) - 4);
        list.push(createPointer(_seed++));
        list.push(createPointer(_seed++));
        list.push(createPointer(_seed++));
        ptr nodePtr_3 = list.push(createPointer(_seed++));
        ptr nodePtr_4 = list.push(createPointer(_seed));
        (ptr node, uint64 i) = list.find(isMatchPtr, abi.encode(nodePtr_4));
        assertEq(ptr.unwrap(node), ptr.unwrap(nodePtr_4));
        assertEq(i, 4);
        (node, i) = list.find(isMatchIndex, abi.encode(3));
        assertEq(ptr.unwrap(node), ptr.unwrap(nodePtr_3));
        assertEq(i, 3);
        (node, i) = list.find(isMatchIndex, abi.encode(10));
        assertEq(ptr.unwrap(node), 0);
        assertEq(i, ~uint64(0));
    }

    function testRfind(uint64 _seed) external {
        vm.assume(_seed != 0);
        vm.assume(_seed < ~uint64(0) - 4);
        list.push(createPointer(_seed++));
        list.push(createPointer(_seed++));
        list.push(createPointer(_seed++));
        ptr nodePtr_3 = list.push(createPointer(_seed++));
        ptr nodePtr_4 = list.push(createPointer(_seed));
        (ptr node, uint64 i) = list.rfind(isMatchPtr, abi.encode(nodePtr_4));
        assertEq(ptr.unwrap(node), ptr.unwrap(nodePtr_4));
        assertEq(i, 4);
        (node, i) = list.rfind(isMatchIndex, abi.encode(3));
        assertEq(ptr.unwrap(node), ptr.unwrap(nodePtr_3));
        assertEq(i, 3);
        (node, i) = list.rfind(isMatchIndex, abi.encode(10));
        assertEq(ptr.unwrap(node), 0);
        assertEq(i, ~uint64(0));
    }

    function testEach(uint64 _seed) external {
        vm.assume(_seed != 0);
        vm.assume(_seed < ~uint64(0) - 4);
        list.push(createPointer(_seed++));
        list.push(createPointer(_seed++));
        list.push(createPointer(_seed++));
        list.push(createPointer(_seed++));
        list.push(createPointer(_seed));
        list.each(onEachIncrementAndStopAtOne, "");
        assertEq(increment, 2);
    }

    function testReach(uint64 _seed) external {
        vm.assume(_seed != 0);
        vm.assume(_seed < ~uint64(0) - 4);
        list.push(createPointer(_seed++));
        list.push(createPointer(_seed++));
        list.push(createPointer(_seed++));
        list.push(createPointer(_seed++));
        list.push(createPointer(_seed));
        list.reach(onEachIncrementAndStopAtOne, "");
        assertEq(increment, 4);
    }

    function testUpdate(uint64 _seed) external {
        vm.assume(_seed != 0);
        vm.assume(_seed < ~uint64(0) - 3);
        ptr nodePtr_0 = list.push(createPointer(_seed++));
        ptr nodePtr_1 = list.push(createPointer(_seed++));
        ptr nodePtr_2 = list.push(createPointer(_seed++));
        assertEq(ptr.unwrap(list.valueAt(nodePtr_1)), _seed - 2);
        assertEq(ptr.unwrap(list.nextAt(nodePtr_1)), ptr.unwrap(nodePtr_2));
        assertEq(ptr.unwrap(list.prevAt(nodePtr_1)), ptr.unwrap(nodePtr_0));
        list.update(nodePtr_1, createPointer(_seed));
        assertEq(ptr.unwrap(list.valueAt(nodePtr_1)), _seed);
        assertEq(ptr.unwrap(list.nextAt(nodePtr_1)), ptr.unwrap(nodePtr_2));
        assertEq(ptr.unwrap(list.prevAt(nodePtr_1)), ptr.unwrap(nodePtr_0));
        vm.expectRevert(InvalidPointer.selector);
        list.update(NULL_PTR, createPointer(_seed));
        vm.expectRevert(InvalidPointer.selector);
        list.update(createPointer(_seed), NULL_PTR);
        vm.expectRevert(InvalidPointer.selector);
        list.update(createPointer(_seed), createPointer(_seed));
    }

    function testInsertBefore(uint64 _seed) public {
        vm.assume(_seed != 0);
        vm.assume(_seed < ~uint64(0) - 2);
        ptr nodePtr_0 = list.insertBefore(NULL_PTR, createPointer(_seed++));
        assertEq(list.length, 1);
        assertEq(ptr.unwrap(list.valueAt(nodePtr_0)), _seed - 1);
        assertEq(ptr.unwrap(list.nextAt(nodePtr_0)), 0);
        assertEq(ptr.unwrap(list.prevAt(nodePtr_0)), 0);
        ptr nodePtr_1 = list.insertBefore(nodePtr_0, createPointer(_seed++));
        assertEq(list.length, 2);
        assertEq(ptr.unwrap(list.valueAt(nodePtr_1)), _seed - 1);
        assertEq(ptr.unwrap(list.nextAt(nodePtr_1)), ptr.unwrap(nodePtr_0));
        assertEq(ptr.unwrap(list.prevAt(nodePtr_1)), 0);
        vm.expectRevert(InvalidPointer.selector);
        list.insertBefore(nodePtr_1, NULL_PTR);
    }

    function testRemove(uint64 _seed) public {
        vm.assume(_seed != 0);
        vm.assume(_seed < ~uint64(0) - 2);
        ptr nodePtr_0 = list.push(createPointer(_seed++));
        ptr nodePtr_1 = list.push(createPointer(_seed++));
        ptr nodePtr_2 = list.push(createPointer(_seed));
        assertEq(list.length, 3);
        list.remove(nodePtr_1);
        assertEq(list.length, 2);
        assertEq(ptr.unwrap(list.valueAt(nodePtr_2)), _seed);
        assertEq(ptr.unwrap(list.nextAt(nodePtr_2)), 0);
        assertEq(ptr.unwrap(list.prevAt(nodePtr_2)), ptr.unwrap(nodePtr_0));
        list.remove(nodePtr_2);
        assertEq(list.length, 1);
        assertEq(ptr.unwrap(list.valueAt(nodePtr_0)), _seed - 2);
        assertEq(ptr.unwrap(list.nextAt(nodePtr_0)), 0);
        assertEq(ptr.unwrap(list.prevAt(nodePtr_0)), 0);
        list.remove(nodePtr_0);
        assertEq(list.length, 0);
        vm.expectRevert(InvalidPointer.selector);
        list.remove(NULL_PTR);
        vm.expectRevert(InvalidPointer.selector);
        list.remove(nodePtr_0);
    }

    function testPop(uint64 _seed) public {
        vm.assume(_seed != 0);
        vm.assume(_seed < ~uint64(0) - 1);
        ptr nodePtr_0 = list.push(createPointer(_seed++));
        ptr nodePtr_1 = list.push(createPointer(_seed));
        assertEq(list.length, 2);
        assertEq(ptr.unwrap(list.valueAt(nodePtr_1)), _seed);
        assertEq(ptr.unwrap(list.nextAt(nodePtr_1)), 0);
        assertEq(ptr.unwrap(list.prevAt(nodePtr_1)), ptr.unwrap(nodePtr_0));
        list.pop();
        assertEq(list.length, 1);
        assertEq(ptr.unwrap(list.valueAt(nodePtr_0)), _seed - 1);
        assertEq(ptr.unwrap(list.nextAt(nodePtr_0)), 0);
        assertEq(ptr.unwrap(list.prevAt(nodePtr_0)), 0);
        list.pop();
        assertEq(list.length, 0);
    }

    function testClear(uint64 _seed) public {
        vm.assume(_seed != 0);
        vm.assume(_seed < ~uint64(0) - 2);
        list.push(createPointer(_seed++));
        list.push(createPointer(_seed++));
        list.push(createPointer(_seed));
        ptr a = list.head;
        ptr b = list.nextAt(list.head);
        ptr c = list.tail;
        assertEq(list.length, 3);
        assertEq(isValidPointer(list.head), true);
        assertEq(isValidPointer(list.tail), true);
        list.clear();
        assertEq(list.length, 0);
        assertEq(isValidPointer(list.head), false);
        assertEq(isValidPointer(list.tail), false);
        assertEq(ptr.unwrap(list.valueAt(a)), 0);
        assertEq(ptr.unwrap(list.valueAt(b)), 0);
        assertEq(ptr.unwrap(list.valueAt(c)), 0);
    }
}
