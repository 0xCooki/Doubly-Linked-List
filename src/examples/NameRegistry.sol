// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {ptr, createPointer, Node, DLL, NULL_PTR, NodeLib, DoublyLinkedListLib} from "src/DoublyLinkedList.sol";

struct Name {
    string first;
    string middle;
    string last;
}

contract NameRegistry {
    using NodeLib for Node;
    using DoublyLinkedListLib for DLL;

    mapping(ptr => Name) public names;

    DLL public registry;

    uint256 private counter;

    constructor () {
        Name memory cooki = Name({
            first: "Cooki",
            middle: "Von",
            last: "Crumble"
        });
        ptr cookiPtr = _createPtrForName(cooki);
        registry.push(cookiPtr);
    }

    function _createPtrForName(Name memory _name) private returns (ptr newPtr) {
        newPtr = createPointer(++counter);
        names[newPtr] = _name;
    }

    function nameAtPosition(uint256 i) external view returns (Name memory) {
        require(i < registry.length, "Invalid Position");
        ptr positionPtr = registry.at(i);
        return names[positionPtr];
    } 

    function addNameAtPosition(uint256 i, Name memory _name) external {
        uint256 length = registry.length;
        require(i <= length, "Invalid Position");
        ptr positionPtr = (i == length) ? NULL_PTR : registry.at(i);
        ptr newPtr = _createPtrForName(_name);
        registry.insertBefore(positionPtr, newPtr);
    }

    function removeNameAtPosition(uint256 i) external {
        require(i < registry.length, "Invalid Position");
        ptr positionPtr = registry.at(i);
        registry.remove(positionPtr);
    }
}