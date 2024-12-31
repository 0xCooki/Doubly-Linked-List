/// SPDX-License-Identifier: MIT
/// @author 0xCooki
pragma solidity ^0.8.8;

import {ptr, createPointer, DLL, NodeLib, Node, NULL_PTR, DoublyLinkedListLib} from "src/DoublyLinkedList.sol";

struct ScoreCard {
    string name;
    uint256 score;
    bool usedBoost;
}

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

    ptr private nodeWinner;
    uint64 private indexWinner;

    function findWinner() external returns (ptr node, uint64 i) {
        board.each(_findWinner, "");
        return (nodeWinner, indexWinner);
    }

    function _findWinner(ptr _node, uint64 _i, bytes memory) private returns (bool) {
        if (cards[board.valueAt(_node)].score > cards[board.valueAt(nodeWinner)].score) {
            nodeWinner = _node;
            indexWinner = _i;
        }
        return true;
    }

    /// Reward Non-boosters

    function rewardNonBoosters() external {
        board.each(_rewardNonBoosters, "");
    }

    function _rewardNonBoosters(ptr _node, uint64, bytes memory) private returns (bool) {
        if (!cards[board.valueAt(_node)].usedBoost) {
            ptr newValuePtr = _createPtrForScoreCard(
                ScoreCard(cards[board.valueAt(_node)].name, cards[board.valueAt(_node)].score + 10, true)
            );
            board.update(_node, newValuePtr);
        }
        return true;
    }
}
