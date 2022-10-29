// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

contract MeshNFT is ERC1155, Ownable, ERC1155Supply {
    uint256 public constant MESH_ID = 0;
    uint256 public price = 0.05 ether;

    constructor() ERC1155("") {}

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function mint(address account, uint256 amount) public payable {
        require(msg.value == price * amount, "Wrong Price!");
        _mint(account, MESH_ID, amount, "");
    }

    function changePrice(uint256 _newPrice) external onlyOwner {
        price = _newPrice;
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override(ERC1155, ERC1155Supply) {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
}
