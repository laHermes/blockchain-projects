// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract QuasiMesh is ERC721Enumerable, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    uint256 public price = 0.03 ether;
    uint256 public maxMintTokens = 10;

    struct Info {
        uint256 id;
        address owner;
        string uri;
    }

    event Skimmed(address indexed account, uint256 indexed amount);

    constructor() ERC721("QuasiMesh", "QM") {}

    function _baseURI() internal pure override returns (string memory) {
        return
            "https://ipfs.io/ipfs/QmWbCfeXfcKF7X25gcXWWau5iaDjxc4w3wUoxdjnwDJdvE/";
    }

    function mintToken(address _to, uint256 _amount) public payable {
        require(
            _to != address(0),
            "QuasiMesh:: mintToken: _to can't be address 0"
        );
        require(_amount != 0, "QuasiMesh:: mintToken: _amount can't be 0");
        require(
            _amount <= maxMintTokens,
            "QuasiMesh:: mintToken: _amount can't be greater than maxMintTokens (10)"
        );

        require(
            msg.value == price * _amount,
            "QuasiMesh:: mintToken: Wrong amount sent!"
        );
        for (uint256 i = 0; i < _amount; i++) {
            safeMint(_to);
        }
    }

    function safeMint(address to) private {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        string memory uriString = string(
            abi.encodePacked(Strings.toString(quasiRandom(tokenId)), ".json")
        );
        _setTokenURI(tokenId, uriString);
    }

    function quasiRandom(uint256 _salt) private view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(block.difficulty, block.timestamp, _salt)
                )
            ) % 10;
    }

    function changePrice(uint256 _newPrice) external onlyOwner {
        price = _newPrice;
    }

    function skim() external onlyOwner {
        (bool success, ) = owner().call{value: address(this).balance}("");
        require(success, "QuasiMesh:: skim: Transaction Failed!");

        emit Skimmed(owner(), address(this).balance);
    }

    function getAllNfts() public view returns (Info[] memory) {
        uint256 totalItemsSize = _tokenIdCounter.current();

        Info[] memory nfts = new Info[](totalItemsSize);

        for (uint256 i = 0; i < totalItemsSize; i++) {
            address ownerAddress = super.ownerOf(i);
            string memory uri = super.tokenURI(i);

            nfts[i] = Info(i, ownerAddress, uri);
        }
        return nfts;
    }

    // The following functions are overrides required by Solidity

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
