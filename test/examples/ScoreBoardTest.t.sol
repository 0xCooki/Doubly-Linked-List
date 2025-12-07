/// SPDX-License-Identifier: MIT
/// @author 0xCooki
pragma solidity ^0.8.8;

import {ptr} from "src/DoublyLinkedList.sol";
import {ScoreBoard, ScoreCard} from "src/examples/ScoreBoard.sol";
import {Test} from "forge-std/Test.sol";

contract ScoreBoardTest is Test {
    ScoreBoard public scoreBoard;

    function setUp() public {
        scoreBoard = new ScoreBoard();
    }

    function testFindLuke() public view {
        (ptr lukePtr,) = scoreBoard.findLuke();
        ScoreCard memory card = scoreBoard.valueAtNode(lukePtr);
        assertEq(card.name, "Luke");
    }

    function testFindWinners() public {
        /// Winner before extra points are allocated
        (ptr winnerPtr,) = scoreBoard.findWinner();
        ScoreCard memory winnerCard = scoreBoard.valueAtNode(winnerPtr);
        assertEq(winnerCard.name, "Jill");
        assertEq(winnerCard.score, 84);
        assertEq(winnerCard.usedBoost, true);
        /// Allocate 10 points to each player who didn't boost
        scoreBoard.rewardNonBoosters();
        /// Winner after extra points are allocated
        (winnerPtr,) = scoreBoard.findWinner();
        winnerCard = scoreBoard.valueAtNode(winnerPtr);
        assertEq(winnerCard.name, "Megan");
        assertEq(winnerCard.score, 85);
        assertEq(winnerCard.usedBoost, true);
    }
}
