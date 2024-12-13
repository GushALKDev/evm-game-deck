// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// Import OpenZeppelin's Ownable contract for access control
import "@openzeppelin/contracts/access/Ownable.sol";
// Import Chainlink's VRFConsumerBaseV2 for requesting random numbers
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
// Import Chainlink's VRFCoordinatorV2Interface to interact with the VRF Coordinator
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

contract HighCard is VRFConsumerBaseV2, Ownable {
    /* State variables */

    // List of players for the game
    address payable[] private s_players;
    // Gas lane (keyHash) for VRF
    bytes32 private immutable i_gasLane;
    // Subscription ID for Chainlink VRF
    uint64 private immutable i_subscriptionId;
    // Gas limit for VRF callback
    uint32 private immutable i_callbackGasLimit;
    // Confirmations required for VRF randomness
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    // Number of random words requested
    uint8 private constant NUM_WORDS = 2;
    // Chainlink VRF Coordinator instance
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;

    // Address of the manager contract
    address managerContractAddress;
    // Game fee percentage
    uint256 fee;

    // Struct to represent a game with two players
    struct Game {
        address player1Address;
        address player2Address;
    }

    // Mapping of game numbers to their respective games
    mapping(uint => Game) public games;
    // Mapping to link VRF request IDs to game numbers
    mapping(uint => uint) public requestIdToGameNumber;

    /* Events */

    // Event emitted when a game ends
    event GameEnded(
        address indexed player1,
        address indexed player2,
        uint player1CardNumber,
        uint player2CardNumber,
        uint player1CardValue,
        uint player2CardValue,
        address indexed winner,
        uint VRFRequestId,
        uint timestamp
    );

    /* Functions */

    // Constructor to initialize contract variables
    constructor(
        address _managerContractAddress,
        uint256 _fee,
        address _vrfCoordinatorV2,        // Chainlink VRF Coordinator address
        bytes32 _gasLane,
        uint64 _subscriptionId,
        uint32 _callbackGasLimit
    ) VRFConsumerBaseV2(_vrfCoordinatorV2) {
        managerContractAddress = _managerContractAddress;
        fee = _fee;
        i_vrfCoordinator = VRFCoordinatorV2Interface(_vrfCoordinatorV2);
        i_gasLane = _gasLane;
        i_subscriptionId = _subscriptionId;
        i_callbackGasLimit = _callbackGasLimit;
    }

    /* Game start */

    // Function to start a new game
    function startGame(address _player1Address, address _player2Address, uint _gameNumber) public {
        // Assign players to the game
        games[_gameNumber].player1Address = _player1Address;
        games[_gameNumber].player2Address = _player2Address;

        // Select the cards for the players (Guide for frontend)
        // numbers 0-12 Trebols - 1(A) 2(2) 3(3) 4(4) 5(5) 5(6) 7(7) 8(8) 9(9) 10(10) 11(Jack) 12(Queen) 13(King)
        // numbers 13-25 Spades - 14(A) 15(2) 16(3) 17(4) 18(5) 19(6) 12(7) 21(8) 22(9) 23(10) 24(Jack) 25(Queen) 26(King)
        // numbers 26-38 Hearts - 27(A) 28(2) 29(3) 30(4) 31(5) 32(6) 33(7) 34(8) 35(9) 36(10) 37(Jack) 38(Queen) 3(King)
        // numbers 39-51 Diamonds - 39(A) 40(2) 41(3) 42(4) 43(5) 44(6) 45(7) 46(8) 47(9) 48(10) 49(Jack) 50(Queen) 51(King)

        // Request random numbers from Chainlink VRF
        uint256 requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQUEST_CONFIRMATIONS,
            i_callbackGasLimit,
            NUM_WORDS
        );

        // Map the VRF request ID to the game number
        requestIdToGameNumber[requestId] = _gameNumber;
    }

    // Function called by VRF Coordinator to provide randomness
    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        // Assign random card numbers to players
        uint player1CardNumber = (randomWords[0] % 52) + 1;
        uint player2CardNumber = (randomWords[1] % 52) + 1;

        // Determine card values for comparison
        uint player1CardValue = player1CardNumber % 13;
        uint player2CardValue = player2CardNumber % 13;

        // Determine the winner based on card values
        address winner;
        if (player1CardValue > player2CardValue) {
            winner = games[requestIdToGameNumber[requestId]].player1Address;
        } else {
            winner = games[requestIdToGameNumber[requestId]].player2Address;
        }

        // Emit the GameEnded event with details
        emit GameEnded(
            games[requestIdToGameNumber[requestId]].player1Address,
            games[requestIdToGameNumber[requestId]].player2Address,
            player1CardNumber,
            player2CardNumber,
            player1CardValue,
            player2CardValue,
            winner,
            requestId,
            block.timestamp
        );

        // Clean up mappings for the completed game
        delete games[requestIdToGameNumber[requestId]];
        delete requestIdToGameNumber[requestId];
    }

    /* View & Pure functions */
}

