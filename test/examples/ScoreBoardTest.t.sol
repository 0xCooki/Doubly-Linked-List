/// SPDX-License-Identifier: MIT
/// @author 0xCooki
pragma solidity ^0.8.8;

import {ptr, Node, DLL, NodeLib, DoublyLinkedListLib, isValidPointer, validatePointer} from "src/DoublyLinkedList.sol";
import {ScoreBoard, ScoreCard} from "src/examples/ScoreBoard.sol";
import {Test, console} from "forge-std/Test.sol";

contract ScoreBoardTest is Test {
    ScoreBoard public scoreBoard;

    function setUp() public {
        scoreBoard = new ScoreBoard();
    }

    function testFindLuke() public view {
        (ptr lukePtr,) = scoreBoard.findLuke();
        (string memory name,,) = scoreBoard.cards(lukePtr);
        assertEq(name, "Luke");
    }

    function testFindWinners() public {
        /// Winner before extra points are allocated
        (ptr winnerPtr,) = scoreBoard.findWinner();
        ScoreCard memory winnerCard = scoreBoard.valueAtNode(winnerPtr);
        assertEq(winnerCard.name, "Jill");
        assertEq(winnerCard.score, 84);
        assertEq(winnerCard.usedBoost, true);

        /// Allocate 10 points to each play who didn't boost
        scoreBoard.rewardNonBoosters();

        /// Winner after extra points are allocated
        (winnerPtr,) = scoreBoard.findWinner();
        winnerCard = scoreBoard.valueAtNode(winnerPtr);
        assertEq(winnerCard.name, "Megan");
        assertEq(winnerCard.score, 85);
        assertEq(winnerCard.usedBoost, true);
    }
}
