// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {ptr, createPointer, Node, DLL, NodeLib, DoublyLinkedListLib} from "src/DoublyLinkedList.sol";

contract NameRegistry {
    using NodeLib for Node;
    using DoublyLinkedListLib for DLL;

    struct Name {
        string first;
        string middle;
        string last;
    }

    mapping(ptr => Name) public names;

    DLL public registry;

    constructor () {
        Name memory cooki = Name({
            first: "Cooki",
            middle: "Von",
            last: "Crumble"
        });
        ptr cookiPtr = _createPtrForName(cooki);
        registry.push(cookiPtr);
    }

    function nameAtPosition(uint256 i) external view returns (Name memory) {
        require(i < registry.length, "Invalid Position");
        ptr positionPtr = registry.at(i);
        return names[positionPtr];
    } 

    function addNameAtPosition(uint256 i, Name memory _name) external {
        require(i <= registry.length, "Invalid Position");
        ptr positionPtr = registry.at(i);
        ptr newPtr = _createPtrForName(_name);
        registry.insertBefore(positionPtr, newPtr);
    }

    function removeNameAtPosition(uint256 i) external {
        require(i < registry.length, "Invalid Position");
        ptr positionPtr = registry.at(i);
        registry.remove(positionPtr);
    }

    /// HELPER ///

    function _createPtrForName(Name memory _name) private returns (ptr newPtr) {
        newPtr = createPointer(block.timestamp);
        names[newPtr] = _name;
    }
}