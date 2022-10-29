// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

contract NFTMarket is ReentrancyGuard, Ownable, ERC721Holder {
    using Counters for Counters.Counter;
    Counters.Counter private _itemIds;
    Counters.Counter private _itemsSold;

    address[] public listedTokens;

    // TODO: Expiry date on sale
    uint256 constant DEFAULT_EXPIRY_DATE = 7 days;
    uint256 constant LISTING_RPICE = 0.01 ether;

    // price in ether
    struct NFTInfo {
        address nftAddress;
        uint256 itemId;
        uint256 tokenId;
        uint256 price;
        address payable owner;
        address payable seller;
        bool forSale;
    }

    mapping(uint256 => NFTInfo) idToNftInfo;

    event ContractEnlisted(address indexed _nftContract);

    event ListingAdded(
        uint256 indexed _id,
        uint256 indexed _tokenId,
        address indexed nftContract,
        uint256 _price
    );

    event ListingRemoved(
        uint256 indexed _id,
        address indexed nftContract,
        uint256 indexed _tokenId
    );
    event BuyToken(uint256 indexed _tokenId);

    modifier onlyTokenOwner(address _nftContract, uint256 _tokenId) {
        require(
            _nftContract != address(0),
            "NFTMarket: Nft contract address is 0"
        );

        address ownerOfToken = IERC721(_nftContract).ownerOf(_tokenId);
        require(
            msg.sender == ownerOfToken,
            "NFTMarket: Sender must be token owner"
        );
        _;
    }

    function marketToken(
        address _nftContract,
        uint256 _tokenId,
        uint256 _price
    ) external payable nonReentrant onlyTokenOwner(_nftContract, _tokenId) {
        require(
            msg.value == LISTING_RPICE,
            "NFTMarket: marketToken:: Listing price must be paid"
        );
        require(
            _price > 0,
            "NFTMarket: marketToken:: Token price must be greater than 0 wei"
        );

        _itemIds.increment();
        uint256 itemId = _itemIds.current();

        IERC721(_nftContract).safeTransferFrom(
            msg.sender,
            address(this),
            _tokenId
        );

        idToNftInfo[itemId] = NFTInfo(
            _nftContract,
            itemId,
            _tokenId,
            _price,
            payable(address(0)),
            payable(msg.sender),
            true
        );
        emit ListingAdded(itemId, _tokenId, _nftContract, _price);
    }

    /* 
    PURCHASE NFT 
    */
    function buyToken(uint256 _nftId) external payable nonReentrant {
        require(
            msg.value == idToNftInfo[_nftId].price,
            "NFTMarket: buyToken:: the price is wrong!"
        );
        require(
            idToNftInfo[_nftId].forSale,
            "NFTMarket: buyToken: NFT not for sale!"
        );

        // change NFT market info
        idToNftInfo[_nftId].forSale = false;
        idToNftInfo[_nftId].seller = payable(msg.sender);

        _itemsSold.increment();

        address nftContractAddress = idToNftInfo[_nftId].nftAddress;
        address seller = idToNftInfo[_nftId].seller;
        uint256 tokenId = idToNftInfo[_nftId].tokenId;
        uint256 price = idToNftInfo[_nftId].price;

        // transfer NFT
        IERC721(nftContractAddress).safeTransferFrom(
            address(this),
            msg.sender,
            tokenId
        );

        // transfer eth
        (bool success, ) = seller.call{value: price}("");

        require(success);

        emit BuyToken(_nftId);
    }

    /* 
    REMOVE FROM LISTING 
    */
    function removeFromListing(uint256 _nftId) external {
        require(
            msg.sender == idToNftInfo[_nftId].seller,
            "NFTMarket: removeFromListing:: Only token owner can unlist the token"
        );

        address contractAddress = idToNftInfo[_nftId].nftAddress;
        uint256 tokenId = idToNftInfo[_nftId].tokenId;

        idToNftInfo[_nftId].forSale = false;

        emit ListingRemoved(_nftId, contractAddress, tokenId);
    }

    function changeNftPrice(uint256 _itemId, uint256 _newPrice) external {
        require(
            msg.sender == idToNftInfo[_itemId].seller,
            "NFTMarket: changeNftPrice:: Only seller can change the token price"
        );
        idToNftInfo[_itemId].price = _newPrice;
    }

    /* 
    GETTERS
    */
    function getNftTokenId(uint256 _id) public view returns (uint256) {
        return idToNftInfo[_id].tokenId;
    }

    function getNftPrice(uint256 _id) public view returns (uint256) {
        return idToNftInfo[_id].price;
    }

    function getNftSeller(uint256 _id) public view returns (address) {
        return idToNftInfo[_id].seller;
    }

    function getNftContract(uint256 _id) public view returns (address) {
        return idToNftInfo[_id].nftAddress;
    }

    function getNftById(uint256 _id) public view returns (NFTInfo memory) {
        return idToNftInfo[_id];
    }

    function getSaleStatus(uint256 _id) public view returns (bool) {
        return idToNftInfo[_id].forSale;
    }

    function getAllNfts() public view returns (NFTInfo[] memory) {
        uint256 totalItemsSize = _itemIds.current();
        uint256 currentIndex;

        NFTInfo[] memory nftItems = new NFTInfo[](totalItemsSize);

        for (uint256 i = 0; i < totalItemsSize; i++) {
            nftItems[currentIndex] = idToNftInfo[i + 1];
            currentIndex++;
        }

        return nftItems;
    }

    function getNftsForSale() public view returns (NFTInfo[] memory) {
        uint256 totalItemsSize = _itemIds.current();
        uint256 nftForSaleCount = 0;

        for (uint256 i = 0; i < totalItemsSize; i++) {
            if (idToNftInfo[i + 1].forSale == true) {
                nftForSaleCount++;
            }
        }

        NFTInfo[] memory nftItems = new NFTInfo[](nftForSaleCount);

        uint256 currentIndex = 0;
        for (uint256 i = 0; i < totalItemsSize; i++) {
            if (idToNftInfo[i + 1].forSale == true) {
                nftItems[currentIndex] = idToNftInfo[i + 1];
                currentIndex++;
            }
        }
        return nftItems;
    }
}
