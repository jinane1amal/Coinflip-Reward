// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "./Dauphine.sol"; 

error SeedTooShort();

contract CoinflipV2 is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    /// @custom:oz-upgrades-unsafe-allow constructor
    string public seed;
    DauphineToken public token;  // Token state variable

    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner) initializer public {
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();
        seed = "It is a good practice to rotate seeds often in gambling";
        token = new DauphineToken(); /
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
    
    // New RewardUser function to mint 5 DAU tokens to the winner
    function RewardUser(address winner) internal {
        uint256 rewardAmount = 5 * 10 ** 18; // If assuming the token uses 18 decimals
        token.mint(winner, rewardAmount);
    }

    /// @notice Allows the owner to change the seed with rotation logic
    /// @param NewSeed is a string representing the new seed
    /// @param rotations is the number of rotations to perform on the seed
    function seedRotation(string memory NewSeed, uint rotations) public onlyOwner {
        bytes memory strngInBts = bytes(NewSeed);
        require(strngInBts.length >= 10, "SeedTooShort");
        
        // Rotation logic: rotates the seed 'rotations' times
        for (uint i = 0; i < rotations; i++) {
            bytes1 lastChar = strngInBts[strngInBts.length - 1];
            for (uint j = strngInBts.length - 1; j > 0; j--) {
                strngInBts[j] = strngInBts[j - 1];
            }
            strngInBts[0] = lastChar;
        }
        seed = string(strngInBts);
    }

    // -------------------- Helper Functions -------------------- //
    /// @notice Generates 10 pseudo-random flips using the seed
    /// @return A fixed array of 10 uint8 values (1 or 0)
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
