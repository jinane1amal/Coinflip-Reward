// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import "../src/Coinflip.sol";
import "../src/CoinflipV2.sol";
import "../Dauphine.sol";

contract ScenarioScript is Script {
    function run() external {
        vm.startBroadcast();

        // Define three addresses: deployer, user, and friend.
        address deployer = vm.addr(1);
        address user = vm.addr(2);
        address friend = vm.addr(3);

        // -------------------------------
        // 1. Deploy the initial Coinflip (V1) contract.
        // -------------------------------
        console.log("Deploying Coinflip V1...");
        Coinflip coinflipV1 = new Coinflip();
        coinflipV1.initialize(deployer);
        console.log("Coinflip V1 deployed at:", address(coinflipV1));

        // -------------------------------
        // 2. User plays on Coinflip V1 and wins.
        // -------------------------------
        // For testing, assume getFlips() returns [1,1,1,1,1,1,1,1,1,1].
        uint8[10] memory winningGuess = [uint8(1), 1, 1, 1, 1, 1, 1, 1, 1, 1];

        console.log("User plays on Coinflip V1...");
        vm.prank(user);
        bool wonV1 = coinflipV1.UserInput(winningGuess);
        require(wonV1, "User did not win on V1 (unexpected)");
        console.log("User won on V1.");

        // -------------------------------
        // 3. Check that the user now has 5 DAU tokens.
        // -------------------------------
        address tokenAddress = coinflipV1.token();
        DauphineToken token = DauphineToken(tokenAddress);
        uint256 userBalance = token.balanceOf(user);
        console.log("User token balance after V1 win (expected 5e18):", userBalance);

        // -------------------------------
        // 4. Upgrade to Coinflip V2.
        // -------------------------------
        console.log("Upgrading to Coinflip V2...");
        CoinflipV2 coinflipV2 = CoinflipV2(address(coinflipV1));
        console.log("Upgrade complete, Coinflip V2 at:", address(coinflipV2));

        // -------------------------------
        // 5. User plays on Coinflip V2 and wins again.
        // -------------------------------
        console.log("User plays on Coinflip V2...");
        vm.prank(user);
        bool wonV2 = coinflipV2.UserInput(winningGuess);
        require(wonV2, "User did not win on V2 (unexpected)");
        console.log("User won on V2.");

        userBalance = token.balanceOf(user);
        console.log("User token balance after V2 win (expected 10e18):", userBalance);

        // -------------------------------
        // 6. User transfers some DAU tokens to their friend.
        // -------------------------------
        uint256 transferAmount = 3 * 10 ** 18;
        console.log("User transfers 3 DAU tokens to friend...");
        vm.prank(user);
        token.transfer(friend, transferAmount);

        uint256 userFinalBalance = token.balanceOf(user);
        uint256 friendBalance = token.balanceOf(friend);
        console.log("Final balances:");
        console.log("User:", userFinalBalance);
        console.log("Friend:", friendBalance);

        vm.stopBroadcast();
    }
}
