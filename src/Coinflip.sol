// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "./Dauphine.sol"; 

error SeedTooShort();

contract Coinflip is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    /// @custom:oz-upgrades-unsafe-allow constructor
    string public seed;
    DauphineToken public token;  // State variable for the token

    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner) initializer public {
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();
        seed = "It is a good practice to rotate seeds often in gambling";
        token = new DauphineToken(); 
        token.transferOwnership(address(this));
    }

    // Updated UserInput function 
    function UserInput(uint8[10] calldata Guesses) external returns(bool) {
        uint8[10] memory flips = getFlips();
        bool win = true;
        for (uint i = 0; i < 10; i++) {
            if (Guesses[i] != flips[i]) {
                win = false;
                break;
            }
        }
        if (win) {
            RewardUser(msg.sender);
        }
        return win;
    }
    
    // New RewardUser function to mint tokens to the winner
    function RewardUser(address winner) internal {
        uint256 rewardAmount = 5 * 10 ** 18; // If assuming token has 18 decimals
        token.mint(winner, rewardAmount);
    }

    /// @notice Allows the owner to change the seed
    function seedRotation(string memory NewSeed) public onlyOwner {
        bytes memory seedBytes = bytes(NewSeed);
        uint seedlength = seedBytes.length;
        if (seedlength < 10) {
            revert SeedTooShort();
        }
        seed = NewSeed;
    }

    // -------------------- Helper Functions -------------------- //
    /// @notice Generates 10 random flips using the seed
    function getFlips() public view returns (uint8[10] memory) {
        bytes memory stringInBytes = bytes(seed);
        uint seedlength = stringInBytes.length;
        uint8[10] memory results;
        uint interval = seedlength / 10;
        for (uint i = 0; i < 10; i++){
            uint randomNum = uint(keccak256(abi.encode(stringInBytes[i * interval], block.timestamp)));
            results[i] = (randomNum % 2 == 0) ? 1 : 0;
        }
        return results;
    }
    
    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}
}
