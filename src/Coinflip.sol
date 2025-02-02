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
    DauphineToken public token; 

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

    function UserInput(uint8[10] calldata Guesses) external view returns(bool){
        uint8[10] memory flips = getFlips();
        for (uint i = 0; i < 10; i++) {
            if (Guesses[i] != flips[i]) {
                return false; 
            }
        }
        return true;
    
    
    }
        /// @notice allows the owner of the contract to change the seed to a new one
    /// @param NewSeed is a string which represents the new seed
    function seedRotation(string memory NewSeed) public onlyOwner {
        // TODO: Cast the string into a bytes array so we may perform operations on it
        bytes memory seedBytes = bytes(NewSeed);

        uint seedlength = seedBytes.length;

        if (seedlength < 10){
            revert SeedTooShort();
        }

        seed = NewSeed;
    }

    // -------------------- helper functions -------------------- //
    /// @notice This function generates 10 random flips by hashing characters of the seed
    /// @return a fixed 10 element array of type uint8 with only 1 or 0 as its elements
    function getFlips() public view returns (uint8[10] memory){
        bytes memory stringInBytes = bytes(seed);
        uint seedlength = stringInBytes.length;

        uint8[10] memory results;

        uint interval = seedlength / 10;

        for (uint i = 0; i < 10; i++){
            // Generating a pseudo-random number by hashing together the character and the block timestamp
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
