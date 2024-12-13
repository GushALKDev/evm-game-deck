
# GAMEDECK

## Introduction

**GAMEDECK** is a modularized project designed to manage and interact with multiple blockchain-based games. It is structured into three separate smart contracts, each responsible for specific functionality:

1. A contract to manage prize pools and interactions with games (pending implementation).
2. A contract for managing the logic of the **TicTacToe** game.
3. A contract for managing the logic of the **HighCard** game.

This modular approach ensures that the games can operate independently while interacting seamlessly with a central prize management system.

---

## Contracts

### 1. Prize Management Contract (Pending Implementation)

- **Purpose**: 
  - Manages the entry fees and prize pools for all games.
  - Holds prizes securely until they are distributed to the winner.
  - Serves as an interface for the games to interact with the prize pools.
  
- **Status**: 
  - Not yet implemented.

---

### 2. TicTacToe Contract

- **Purpose**:
  - Handles the logic for a classic **Tic Tac Toe** game.
  - Allows two players to compete on a 3x3 grid.
  - Determines the winner or a draw based on the game's state.

- **Key Features**:
  - **Game Management**:
    - Start new games between two players.
    - Track the current player's turn and total moves.
  - **Validation**:
    - Ensures valid moves within the grid.
    - Checks for game-ending conditions (win or draw).
  - **Error Handling**:
    - Provides custom errors for invalid actions (e.g., invalid moves, playing out of turn).
  - **Events**:
    - Emits events for each move and when a game ends.

---

### 3. HighCard Contract

- **Purpose**:
  - Implements the logic for a card-based game called **HighCard**.
  - Allows two players to compete by drawing random cards to determine the winner.

- **Key Features**:
  - **Randomness**:
    - Integrates with **Chainlink VRF** for secure and verifiable random card draws.
  - **Game Management**:
    - Supports starting games with two players.
    - Tracks player cards, card values, and total movements.
  - **Error Handling**:
    - Provides custom errors for invalid actions (e.g., duplicate games, invalid game numbers).
  - **Events**:
    - Emits events for game results, including the winner and card details.

---

## How It Works

1. **Prize Pool Management**:
   - The central prize management contract (Contract 1) will serve as the entry point for all games. Players enter by paying a fee, which is stored securely until the game concludes.

2. **TicTacToe**:
   - Players initiate a game by providing their addresses.
   - Turns alternate as players make moves on a 3x3 board.
   - The game ends when a player wins (row, column, or diagonal) or the board is full (draw).

3. **HighCard**:
   - Players start a game, and random cards are assigned using Chainlink VRF.
   - The player with the higher card value wins.
   - Events are emitted for transparency, and game data is cleaned after completion.

---

## Installation

1. **Clone the Repository**:
   ```bash
   git clone <repository-url>
   cd GAMEDECK
   ```

2. **Install Dependencies**:
   Ensure you have Node.js and Yarn installed.
   ```bash
   yarn
   ```

3. **Compile the Contracts**:
   Use Hardhat to compile the smart contracts.
   ```bash
   npx hardhat compile
   ```

4. **Deploy the Contracts**:
   Deploy the contracts to your preferred blockchain network.
   ```bash
   npx hardhat run scripts/deploy.js --network <network-name>
   ```

---

## Usage

1. **TicTacToe**:
   - Call the `startGame` function with the addresses of two players.
   - Use the `Move` function to make moves for the current player.
   - Listen for the `GameMovement` and `GameEnded` events.

2. **HighCard**:
   - Call the `startGame` function with the addresses of two players and a game number.
   - Wait for the `GameEnded` event to determine the winner and card details.

---

## Future Improvements

- **Prize Management Contract**:
  - Implement the central contract to handle entry fees and prize distribution.
  - Add functions for interacting with multiple games seamlessly.

- **Game Variety**:
  - Expand the project to include additional games with modular logic.

- **Frontend Integration**:
  - Develop a user-friendly interface to interact with the contracts.

- **Optimized Gas Usage**:
  - Refactor game logic to reduce gas costs.

