// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Punks is ERC721Enumerable, AccessControl, Ownable {
    event Skimmed(address indexed account, uint256 indexed amount);

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    uint256 public TOKEN_PRICE = 0.01 ether;

    address public immutable artist;

    string public BASE_URI = "";

    constructor(string memory _name, string memory _abbrev)
        ERC721(_name, _abbrev)
    {
        _setupRole(ADMIN_ROLE, msg.sender);
        artist = msg.sender;
    }

    receive() external payable {}

    fallback() external payable {}

    function mintToken(address _to) public payable {
        require(
            msg.value == TOKEN_PRICE,
            "Punks: safeMint:: Please send the right amount of tokens!"
        );

        _safeMint(_to, totalSupply() + 1);
    }

    function skim() external onlyRole(ADMIN_ROLE) {
        (bool success, ) = owner().call{value: address(this).balance}("");
        require(success, "Punks: skim:: Transaction Failed!");

        emit Skimmed(owner(), address(this).balance);
    }

    function setBaseURI(string memory baseURI) public onlyRole(ADMIN_ROLE) {
        BASE_URI = baseURI;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return BASE_URI;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Enumerable, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
