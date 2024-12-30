// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {ptr, createPointer, DLL, NULL_PTR, DoublyLinkedListLib} from "src/DoublyLinkedList.sol";

struct ScoreCard {
    string name;
    uint256 score;
    bool usedBoost;
}

/// @dev need to use find and each, and make the data structure complicated as a mapping of DLLs?
contract ScoreBoard {
    using DoublyLinkedListLib for DLL;

    mapping(ptr => ScoreCard) public cards;

    DLL public board;

    uint256 private counter;

    function _createPtrForScoreCard(ScoreCard memory _card) private returns (ptr newPtr) {
        newPtr = createPointer(++counter);
        cards[newPtr] = _card;
    }

    
}