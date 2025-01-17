/// SPDX-License-Identifier: MIT
/// @author 0xCooki
pragma solidity ^0.8.8;

import {DoublyLinkedListBytes} from "src/extensions/DoublyLinkedListBytes.sol";

contract NameRegistry is DoublyLinkedListBytes {
    constructor() {
        addValueAtPosition(0, "Cooki");
    }
}

/// Note override all state-changing functions to ensure only the contract creator can modify the list.
contract GatedNameRegistry is DoublyLinkedListBytes {
    address public immutable owner;

    modifier onlyOwner() {
        if (msg.sender != owner) revert();
        _;
    }

    constructor() {
        owner = msg.sender;
        addValueAtPosition(0, "Cookie");
        amendValueAtPosition(0, "Cooki");
        removeValueAtPosition(0);
        push('Cooki');
        push('Cookie');
        pop();
    }

    function addValueAtPosition(uint64 _i, bytes memory _value) public override onlyOwner {
        super.addValueAtPosition(_i, _value);
    }

    function amendValueAtPosition(uint64 _i, bytes memory _value) public override onlyOwner {
        super.amendValueAtPosition(_i, _value);
    }

    function removeValueAtPosition(uint64 _i) public override onlyOwner {
        super.removeValueAtPosition(_i);
    }

    function push(bytes memory _value) public override onlyOwner {
        super.push(_value);
    }

    function pop() public override onlyOwner {
        super.pop();
    }
}
