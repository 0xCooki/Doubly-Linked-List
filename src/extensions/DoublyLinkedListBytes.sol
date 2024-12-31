/// SPDX-License-Identifier: MIT
/// @author 0xCooki
pragma solidity ^0.8.8;

import {ptr, createPointer, DLL, NULL_PTR, DoublyLinkedListLib} from "src/DoublyLinkedList.sol";

contract DoublyLinkedListBytes {
    using DoublyLinkedListLib for DLL;

    mapping(ptr => bytes) public values;

    DLL public list;

    uint64 private counter;

    error InvalidPosition();

    /// PUBLIC ///

    function addValueAtPosition(uint64 _i, bytes memory _value) public virtual {
        if (_i > list.length) revert InvalidPosition();
        ptr positionPtr = (_i == list.length) ? NULL_PTR : list.at(_i);
        ptr valuePtr = _createPtrForValue(_value);
        list.insertBefore(positionPtr, valuePtr);
    }

    function amendValueAtPosition(uint64 _i, bytes memory _value) public virtual {
        if (_i >= list.length) revert InvalidPosition();
        ptr positionPtr = list.at(_i);
        ptr valuePtr = _createPtrForValue(_value);
        list.update(positionPtr, valuePtr);
    }

    function removeValueAtPosition(uint64 _i) public virtual {
        if (_i >= list.length) revert InvalidPosition();
        ptr positionPtr = list.at(_i);
        list.remove(positionPtr);
    }

    function push(bytes memory _value) public virtual {
        ptr valuePtr = _createPtrForValue(_value);
        list.insertBefore(NULL_PTR, valuePtr);
    }

    function pop() public virtual {
        list.remove(list.tail);
    }

    /// VIEW ///

    function valueAtPosition(uint64 _i) public view virtual returns (bytes memory) {
        if (_i >= list.length) revert InvalidPosition();
        ptr positionPtr = list.at(_i);
        ptr valuePtr = list.valueAt(positionPtr);
        return values[valuePtr];
    }

    function length() public view virtual returns (uint64) {
        return list.length;
    }

    /// PRIVATE ///

    function _createPtrForValue(bytes memory _value) private returns (ptr newPtr) {
        newPtr = createPointer(++counter);
        values[newPtr] = _value;
    }
}
