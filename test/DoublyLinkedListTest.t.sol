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
    ListEmpty,
    createPointer,
    isValidPointer,
    validatePointer,
    NodeLib,
    DoublyLinkedListLib
} from "src/DoublyLinkedList.sol";
import {Test, console, StdStorage, stdStorage} from "forge-std/Test.sol";

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
    }

    function testIsValidNode() public view {
        assertEq(node.isValidNode(), false);
    }

    function testValidateNode() public {
        vm.expectRevert(InvalidPointer.selector);
        node.validateNode();
    }

    function testSet(uint64 _seed) public {
        vm.assume(_seed != 0);
        ptr newPtr = createPointer(_seed);
        node.set(newPtr, newPtr, newPtr);
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
        node.set(newPtr, newPtr, newPtr);
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
        assertEq(list.counter, 0);
        assertEq(list.length, 0);
        assertEq(isValidPointer(list.head), false);
        assertEq(isValidPointer(list.tail), false);
    }

    function testStoragePacking() public {
        list.counter = 0x1111111111111111;
        list.length = 0x2222222222222222;
        list.head = ptr.wrap(0x3333333333333333);
        list.tail = ptr.wrap(0x4444444444444444);
        uint256 slotNumber = stdstore.enable_packed_slots().target(address(this)).sig("list()").depth(0).find();
        bytes32 slot = vm.load(address(this), bytes32(slotNumber));
        assertEq(uint64(uint256(slot)), 0x1111111111111111, "counter");
        assertEq(uint64(uint256(slot) >> 64), 0x2222222222222222, "length");
        assertEq(uint64(uint256(slot) >> 128), 0x3333333333333333, "head");
        assertEq(uint64(uint256(slot) >> 192), 0x4444444444444444, "tail");
    }

    function testValueAt(uint64 _seed) public {
        vm.assume(_seed != 0);
        ptr newValuePtr = createPointer(_seed);
        ptr nodePtr = createPointer(1);
        assertEq(ptr.unwrap(list.valueAt(nodePtr)), 0);
        list.push(newValuePtr);
        assertEq(list.counter, 1);
        assertEq(ptr.unwrap(list.valueAt(nodePtr)), ptr.unwrap(newValuePtr));
    }

    function testNextAt(uint64 _seed) public {
        vm.assume(_seed != 0);
        ptr newValuePtr = createPointer(_seed);
        list.push(newValuePtr);
        assertEq(list.counter, 1);
        ptr nodePtr = createPointer(1);
        assertEq(ptr.unwrap(list.nextAt(nodePtr)), 0);
    }

    function testPrevAt(uint64 _seed) public {
        vm.assume(_seed != 0);
        ptr newValuePtr = createPointer(_seed);
        list.push(newValuePtr);
        assertEq(list.counter, 1);
        ptr nodePtr = createPointer(1);
        assertEq(ptr.unwrap(list.prevAt(nodePtr)), 0);
    }

    function testAt(uint64 _seed) public {
        vm.assume(_seed != 0);
        vm.assume(_seed < ~uint64(0) - 4);
        list.push(createPointer(_seed++));
        list.push(createPointer(_seed++));
        list.push(createPointer(_seed++));
        list.push(createPointer(_seed++));
        list.push(createPointer(_seed));
        assertEq(list.counter, 5);
        assertEq(ptr.unwrap(list.at(0)), 1);
        assertEq(ptr.unwrap(list.at(1)), 2);
        assertEq(ptr.unwrap(list.at(2)), 3);
        assertEq(ptr.unwrap(list.at(3)), 4);
        assertEq(ptr.unwrap(list.at(4)), 5);
        vm.expectRevert(InvalidLength.selector);
        list.at(5);
    }

    function testFind(uint64 _seed) external {
        vm.assume(_seed != 0);
        vm.assume(_seed < ~uint64(0) - 4);
        list.push(createPointer(_seed++));
        list.push(createPointer(_seed++));
        list.push(createPointer(_seed++));
        list.push(createPointer(_seed++));
        list.push(createPointer(_seed));
        assertEq(list.counter, 5);
        (ptr node, uint64 i) = list.find(isMatchPtr, abi.encode(ptr.wrap(5)));
        assertEq(ptr.unwrap(node), 5);
        assertEq(i, 4);
        (node, i) = list.find(isMatchIndex, abi.encode(3));
        assertEq(ptr.unwrap(node), 4);
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
        list.push(createPointer(_seed++));
        list.push(createPointer(_seed));
        assertEq(list.counter, 5);
        (ptr node, uint64 i) = list.rfind(isMatchPtr, abi.encode(ptr.wrap(5)));
        assertEq(ptr.unwrap(node), 5);
        assertEq(i, 4);
        (node, i) = list.rfind(isMatchIndex, abi.encode(3));
        assertEq(ptr.unwrap(node), 4);
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
        assertEq(list.counter, 5);
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
        assertEq(list.counter, 5);
        list.reach(onEachIncrementAndStopAtOne, "");
        assertEq(increment, 4);
    }

    function testUpdate(uint64 _seed) external {
        vm.assume(_seed != 0);
        vm.assume(_seed < ~uint64(0) - 3);
        list.push(createPointer(_seed++));
        list.push(createPointer(_seed++));
        list.push(createPointer(_seed++));
        assertEq(list.counter, 3);
        ptr nodePtr = ptr.wrap(2);
        assertEq(ptr.unwrap(list.valueAt(nodePtr)), _seed - 2);
        assertEq(ptr.unwrap(list.nextAt(nodePtr)), 3);
        assertEq(ptr.unwrap(list.prevAt(nodePtr)), 1);
        list.update(nodePtr, createPointer(_seed));
        assertEq(ptr.unwrap(list.valueAt(nodePtr)), _seed);
        assertEq(ptr.unwrap(list.nextAt(nodePtr)), 3);
        assertEq(ptr.unwrap(list.prevAt(nodePtr)), 1);
        vm.expectRevert(InvalidPointer.selector);
        list.update(NULL_PTR, createPointer(_seed));
        vm.expectRevert(InvalidPointer.selector);
        list.update(createPointer(_seed), NULL_PTR);
        vm.expectRevert(InvalidPointer.selector);
        list.update(ptr.wrap(4), createPointer(_seed));
    }

    function testInsertBefore(uint64 _seed) public {
        vm.assume(_seed != 0);
        vm.assume(_seed < ~uint64(0) - 2);
        list.insertBefore(NULL_PTR, createPointer(_seed++));
        ptr nodePtr = ptr.wrap(1);
        assertEq(list.length, 1);
        assertEq(ptr.unwrap(list.valueAt(nodePtr)), _seed - 1);
        assertEq(ptr.unwrap(list.nextAt(nodePtr)), 0);
        assertEq(ptr.unwrap(list.prevAt(nodePtr)), 0);
        list.insertBefore(nodePtr, createPointer(_seed++));
        nodePtr = ptr.wrap(2);
        assertEq(list.length, 2);
        assertEq(ptr.unwrap(list.valueAt(nodePtr)), _seed - 1);
        assertEq(ptr.unwrap(list.nextAt(nodePtr)), 1);
        assertEq(ptr.unwrap(list.prevAt(nodePtr)), 0);
        vm.expectRevert(InvalidPointer.selector);
        list.insertBefore(nodePtr, NULL_PTR);
    }

    function testRemove(uint64 _seed) public {
        vm.assume(_seed != 0);
        vm.assume(_seed < ~uint64(0) - 2);
        list.push(createPointer(_seed++));
        list.push(createPointer(_seed++));
        list.push(createPointer(_seed));
        assertEq(list.length, 3);
        ptr nodePtr = ptr.wrap(2);
        list.remove(nodePtr);
        nodePtr = ptr.wrap(3);
        assertEq(list.length, 2);
        assertEq(ptr.unwrap(list.valueAt(nodePtr)), _seed);
        assertEq(ptr.unwrap(list.nextAt(nodePtr)), 0);
        assertEq(ptr.unwrap(list.prevAt(nodePtr)), 1);
        list.remove(nodePtr);
        nodePtr = ptr.wrap(1);
        assertEq(list.length, 1);
        assertEq(ptr.unwrap(list.valueAt(nodePtr)), _seed - 2);
        assertEq(ptr.unwrap(list.nextAt(nodePtr)), 0);
        assertEq(ptr.unwrap(list.prevAt(nodePtr)), 0);
        list.remove(nodePtr);
        nodePtr = ptr.wrap(1);
        assertEq(list.length, 0);
        vm.expectRevert(InvalidPointer.selector);
        list.remove(NULL_PTR);
        vm.expectRevert(InvalidPointer.selector);
        list.remove(nodePtr);
    }

    function testPop(uint64 _seed) public {
        vm.assume(_seed != 0);
        vm.assume(_seed < ~uint64(0) - 1);
        list.push(createPointer(_seed++));
        list.push(createPointer(_seed));
        assertEq(list.length, 2);
        ptr nodePtr = ptr.wrap(2);
        assertEq(ptr.unwrap(list.valueAt(nodePtr)), _seed);
        assertEq(ptr.unwrap(list.nextAt(nodePtr)), 0);
        assertEq(ptr.unwrap(list.prevAt(nodePtr)), 1);
        list.pop();
        assertEq(list.length, 1);
        nodePtr = ptr.wrap(1);
        assertEq(ptr.unwrap(list.valueAt(nodePtr)), _seed - 1);
        assertEq(ptr.unwrap(list.nextAt(nodePtr)), 0);
        assertEq(ptr.unwrap(list.prevAt(nodePtr)), 0);
        list.pop();
        assertEq(list.length, 0);
    }

    function testClear(uint64 _seed) public {
        vm.assume(_seed != 0);
        vm.assume(_seed < ~uint64(0) - 2);
        list.push(createPointer(_seed++));
        list.push(createPointer(_seed++));
        list.push(createPointer(_seed));

        /// get pointer for current head
        ptr currentHead = list.head;

        assertEq(list.length, 3);
        assertEq(isValidPointer(list.head), true);
        assertEq(isValidPointer(list.tail), true);
        list.clear();
        assertEq(list.length, 0);
        assertEq(isValidPointer(list.head), false);
        assertEq(isValidPointer(list.tail), false);

        /// But it persists in the list
        assertEq(ptr.unwrap(list.valueAt(currentHead)), _seed - 2);
    }
}
