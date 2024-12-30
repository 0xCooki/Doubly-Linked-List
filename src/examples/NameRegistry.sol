// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {ptr, createPointer, DLL, NULL_PTR, DoublyLinkedListLib} from "src/DoublyLinkedList.sol";

/// @dev shows basic DLL use of indexed adding, removing, and accessing data in the list
/// should add an amend function too and maybe find a way to use pop and push for a swap
contract NameRegistry {
    using DoublyLinkedListLib for DLL;

    mapping(ptr => string) public names;

    DLL public registry;

    uint64 private counter;

    constructor() {
        ptr cookiPtr = _createPtrForName("Cooki");
        registry.push(cookiPtr);
    }

    function _createPtrForName(string memory _name) private returns (ptr newPtr) {
        newPtr = createPointer(++counter);
        names[newPtr] = _name;
    }

    function nameAtPosition(uint64 i) external view returns (string memory) {
        require(i < registry.length, "Invalid Position");
        ptr positionPtr = registry.at(i);
        ptr valuePtr = registry.valueAt(positionPtr);
        return names[valuePtr];
    }

    function addNameAtPosition(uint64 i, string memory _name) external {
        uint256 length = registry.length;
        require(i <= length, "Invalid Position");
        ptr positionPtr = (i == length) ? NULL_PTR : registry.at(i);
        ptr valuePtr = _createPtrForName(_name);
        registry.insertBefore(positionPtr, valuePtr);
    }

    function amendNameAtPosition(uint64 i, string memory _name) external {
        require(i < registry.length, "Invalid Position");
        ptr positionPtr = registry.at(i);
        ptr valuePtr = _createPtrForName(_name);
        registry.update(positionPtr, valuePtr);
    }

    function removeNameAtPosition(uint64 i) external {
        require(i < registry.length, "Invalid Position");
        ptr positionPtr = registry.at(i);
        registry.remove(positionPtr);
    }
}
