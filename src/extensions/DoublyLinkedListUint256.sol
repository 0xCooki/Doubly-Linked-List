/// SPDX-License-Identifier: MIT
/// @author 0xCooki
pragma solidity ^0.8.8;

import {ptr, createPointer, DLL, NULL_PTR, DoublyLinkedListLib} from "src/DoublyLinkedList.sol";

contract DoublyLinkedListUint256 {
    using DoublyLinkedListLib for DLL;

    mapping(ptr => uint256) public values;

    DLL public list;

    uint64 private counter;

    error InvalidPosition();

    /// VIEW ///

    function valueAtPosition(uint64 _i) public view virtual returns (uint256) {
        if (_i >= list.length) revert InvalidPosition();
        ptr positionPtr = list.at(_i);
        ptr valuePtr = list.valueAt(positionPtr);
        return values[valuePtr];
    }

    function length() public view virtual returns (uint64) {
        return list.length;
    }

    /// INTERNAL ///

    function _addValueAtPosition(uint64 _i, uint256 _value) internal virtual {
        if (_i > list.length) revert InvalidPosition();
        ptr positionPtr = (_i == list.length) ? NULL_PTR : list.at(_i);
        ptr valuePtr = _createPtrForValue(_value);
        list.insertBefore(positionPtr, valuePtr);
    }

    function _amendValueAtPosition(uint64 _i, uint256 _value) internal virtual {
        if (_i >= list.length) revert InvalidPosition();
        ptr positionPtr = list.at(_i);
        ptr valuePtr = _createPtrForValue(_value);
        list.update(positionPtr, valuePtr);
    }

    function _removeValueAtPosition(uint64 _i) internal virtual {
        if (_i >= list.length) revert InvalidPosition();
        ptr positionPtr = list.at(_i);
        list.remove(positionPtr);
    }

    function _push(uint256 _value) internal virtual {
        ptr valuePtr = _createPtrForValue(_value);
        list.insertBefore(NULL_PTR, valuePtr);
    }

    function _pop() internal virtual {
        list.remove(list.tail);
    }

    function _createPtrForValue(uint256 _value) private returns (ptr newPtr) {
        newPtr = createPointer(++counter);
        values[newPtr] = _value;
    }
}
