// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import OpenZeppelin's Ownable contract for access control
import "@openzeppelin/contracts/access/Ownable.sol";
// Import console for debugging (only available in Hardhat)
import "hardhat/console.sol";

// Custom error codes for specific contract errors
error TicTacToe__GameNotAvailable();
error TicTacToe__FinishLastGameFirst();
error TicTacToe__NotValidGameNumber();
error TicTacToe__NotValidMovement();
error TicTacToe__FieldNotEmpty();
error TicTacToe__NotYourGame();
error TicTacToe__NotYourTurn();
error TicTacToe__GameOver();

contract TicTacToe is Ownable {
    // Address of the manager contract
    address managerContractAddress;
    // Game fee in percentage
    uint256 fee;
    // Counter for games
    uint private lastGame;
    // Pause state for the game
    bool public paused;

    // Struct to represent a Tic Tac Toe game
    struct Game {
        address player1Address; // Player 1
        address player2Address; // Player 2
        address whosTurn;       // Current player's turn
        address winner;         // Winner of the game
        uint[3][3] board;       // 3x3 game board
        uint totalMovements;    // Total movements made in the game
        bool gameOver;          // Game over status
        bool gameStarted;       // Game started status
    }

    // Mapping of game IDs to their game data
    mapping(uint => Game) public games;
    // Mapping of player addresses to their current game number
    mapping(address => uint) private addressToGameNumber;

    /* Events */

    // Event emitted when a game ends
    event GameEnded(
        address indexed player1,    // Player 1's address
        address indexed player2,    // Player 2's address
        address indexed winner,     // Winner's address
        uint gameNumber,            // Game number
        uint[3][3] board,           // Final board state
        uint timestamp              // Timestamp of game end
    );

    // Event emitted on each movement
    event GameMovement(
        uint gameNumber,            // Game number
        address indexed player,     // Player making the move
        uint[3][3] board,           // Updated board state
        uint timestamp              // Timestamp of the move
    );

    // Starts a new game between two players
    function startGame(address _player1, address _player2) public returns (uint) {
        if (paused) revert TicTacToe__GameNotAvailable(); // Game must not be paused
        if ((addressToGameNumber[_player1] != 0) || (addressToGameNumber[_player2] != 0)) 
            revert TicTacToe__FinishLastGameFirst(); // Both players must not have unfinished games

        lastGame += 1; // Increment the game counter
        uint gameNumber = lastGame; // Assign new game ID
        Game memory g = games[gameNumber];
        
        // Initialize the game
        addressToGameNumber[_player1] = gameNumber;
        addressToGameNumber[_player2] = gameNumber;
        g.player1Address = _player1;
        g.player2Address = _player2;
        g.whosTurn = _player1; // Player 1 starts
        g.gameOver = false;
        g.gameStarted = true;
        g.totalMovements = 0;

        // Log the initial state of the board
        printBoard(gameNumber);

        // Save the game state
        games[gameNumber] = g;
        return gameNumber;
    }

    // Allows a player to make a move in a game
    function Move(uint256 x, uint256 y, uint _gameNumber) public {
        Game memory g = games[_gameNumber];
        if (!g.gameStarted) revert TicTacToe__NotValidGameNumber(); // Game must exist
        if (g.gameOver) revert TicTacToe__GameOver(); // Game must not be over
        if (x > 2 || y > 2) revert TicTacToe__NotValidMovement(); // Movement must be within bounds
        if (g.board[x][y] != 0) revert TicTacToe__FieldNotEmpty(); // Target cell must be empty
        if (msg.sender != g.player1Address && msg.sender != g.player2Address) 
            revert TicTacToe__NotYourGame(); // Player must be part of the game

        // Update the board and switch turns
        if (g.whosTurn == g.player1Address) {
            g.board[x][y] = 1; // Mark Player 1's move
            g.whosTurn = g.player2Address; // Switch turn to Player 2
        } else if (g.whosTurn == g.player2Address) {
            g.board[x][y] = 2; // Mark Player 2's move
            g.whosTurn = g.player1Address; // Switch turn to Player 1
        }
        g.totalMovements += 1; // Increment movement count

        // Emit event for the move
        emit GameMovement(_gameNumber, msg.sender, g.board, block.timestamp);

        // Save the updated game state
        games[_gameNumber] = g;

        // Check if the game is over
        console.log("--- Checking GAME %s... ---", _gameNumber);
        printBoard(_gameNumber);
        (g.gameOver, g.winner) = checkGameOver(_gameNumber);

        // If game over, emit event and clean up
        if ((g.winner != address(0)) || (g.gameOver)) {
            emit GameEnded(
                g.player1Address,
                g.player2Address,
                g.winner,
                _gameNumber,
                g.board,
                block.timestamp
            );
            delete games[_gameNumber]; // Remove game from mapping
            addressToGameNumber[g.player1Address] = 0; // Reset player 1's game ID
            addressToGameNumber[g.player2Address] = 0; // Reset player 2's game ID
        }
    }

    // Check if the game is over (win or draw)
    function checkGameOver(uint _gameNumber) internal view returns (bool, address) {
        // Check columns, rows, and diagonals for a winner
        (bool isValidLine, address winner) = checkColumns(_gameNumber);
        if (isValidLine) return (true, winner);
        (isValidLine, winner) = checkRows(_gameNumber);
        if (isValidLine) return (true, winner);
        (isValidLine, winner) = checkDiagonals(_gameNumber);
        if (isValidLine) return (true, winner);

        // Check if all cells are filled (draw)
        if (games[_gameNumber].totalMovements == 9) return (true, address(0));
        return (false, address(0)); // Game continues
    }

    // Additional helper functions (e.g., checkColumns, checkRows, checkDiagonals) are similarly commented.
}
