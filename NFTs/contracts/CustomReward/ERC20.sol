// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TakoToken is ERC20 {
    constructor() ERC20("Tako", "Nesto") {
        _mint(msg.sender, (10 * 10) ^ 18);
    }
}
