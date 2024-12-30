// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {ptr, createPointer, DLL, NodeLib, Node, NULL_PTR, DoublyLinkedListLib} from "src/DoublyLinkedList.sol";

struct ScoreCard {
    string name;
    uint256 score;
    bool usedBoost;
}

/// @dev need to use find and each, and make the data structure complicated as a mapping of DLLs?
contract ScoreBoard {
    using NodeLib for Node;
    using DoublyLinkedListLib for DLL;

    mapping(ptr => ScoreCard) public cards;

    DLL public board;

    uint64 private counter;

    constructor() {
        board.push(_createPtrForScoreCard(ScoreCard("Simon", 50, false)));
        board.push(_createPtrForScoreCard(ScoreCard("James", 77, true)));
        board.push(_createPtrForScoreCard(ScoreCard("Emily", 58, false)));
        board.push(_createPtrForScoreCard(ScoreCard("Megan", 21, true)));
        board.push(_createPtrForScoreCard(ScoreCard("Willis", 40, false)));
        board.push(_createPtrForScoreCard(ScoreCard("Luke", 71, false)));
        board.push(_createPtrForScoreCard(ScoreCard("Viktor", 39, true)));
        board.push(_createPtrForScoreCard(ScoreCard("Frances", 61, false)));
        board.push(_createPtrForScoreCard(ScoreCard("Jill", 84, true)));
        board.push(_createPtrForScoreCard(ScoreCard("Sean", 43, true)));
    }

    function _createPtrForScoreCard(ScoreCard memory _card) private returns (ptr newPtr) {
        newPtr = createPointer(++counter);
        cards[newPtr] = _card;
    }

    /// Find Luke
    function findLuke() external view returns (ptr node, uint64 i) {
        (node, i) = board.find(_findLuke, "");
    }

    function _findLuke(ptr _node, uint64, bytes memory) private view returns (bool) {
        return (keccak256(abi.encodePacked(cards[board.valueAt(_node)].name)) == keccak256(abi.encodePacked("Luke")));
    }

    /// Find Winner

    
}
