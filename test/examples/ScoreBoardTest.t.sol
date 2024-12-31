/// SPDX-License-Identifier: MIT
/// @author 0xCooki
pragma solidity ^0.8.8;

import {ptr, Node, DLL, NodeLib, DoublyLinkedListLib, isValidPointer, validatePointer} from "src/DoublyLinkedList.sol";
import {ScoreBoard} from "src/examples/ScoreBoard.sol";
import {Test, console} from "forge-std/Test.sol";

contract ScoreBoardTest is Test {
    using NodeLib for Node;
    using DoublyLinkedListLib for DLL;

    ScoreBoard public scoreBoard;

    function setUp() public {
        scoreBoard = new ScoreBoard();
    }

    function init() public {}
}
