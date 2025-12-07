/// SPDX-License-Identifier: MIT
/// @author 0xCooki
pragma solidity ^0.8.8;

import {ptr, createPointer, DLL, DoublyLinkedListLib} from "src/DoublyLinkedList.sol";

struct ScoreCard {
    string name;
    uint256 score;
    bool usedBoost;
}

contract ScoreBoard {
    using DoublyLinkedListLib for DLL;

    DLL private board;

    uint64 private counter;

    mapping(ptr => ScoreCard) private cards;

    constructor() {
        board.push(_createPtrForScoreCard(ScoreCard("Simon", 21, false)));
        board.push(_createPtrForScoreCard(ScoreCard("James", 77, true)));
        board.push(_createPtrForScoreCard(ScoreCard("Emily", 58, false)));
        board.push(_createPtrForScoreCard(ScoreCard("Megan", 75, false)));
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

    function valueAtNode(ptr _ptr) external view returns (ScoreCard memory) {
        ptr valuePtr = board.valueAt(_ptr);
        return cards[valuePtr];
    }

    /// FIND LUKE ///

    function findLuke() external view returns (ptr node, uint64 i) {
        (node, i) = board.find(_findLuke, "");
    }

    function _findLuke(ptr _node, uint64, bytes memory) private view returns (bool) {
        return (keccak256(abi.encodePacked(cards[board.valueAt(_node)].name)) == keccak256(abi.encodePacked("Luke")));
    }

    /// FIND WINNER ///

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

    /// REWARD NON-BOOSTERS ///

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
