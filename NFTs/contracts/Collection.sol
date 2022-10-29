// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CollectionBundle is ERC721Enumerable, AccessControl, Ownable {
    event SaleStatus(bool indexed status);
    event Airdrop(address indexed account);
    event Skimmed(address indexed account, uint256 indexed amount);
    event BaseUri(string indexed uri);

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    uint256 public MAX_TOKENS_AMOUNT = 100;
    uint256 public TOKEN_PRICE = 0.01 ether;

    address public immutable developer;

    // change URI
    string public BASE_URI =
        "ipfs://QmWkkDwEtqRxnSfrbPfqVZm4fttuKY3GuvxJqsdD2FSCjn/";

    bool public openSale = false;

    address[] public airdropAddresses;

    modifier isSaleOpen() {
        require(openSale, "Collection: Sale is closed!");
        _;
    }

    constructor(string memory _name, string memory _abbrev)
        ERC721(_name, _abbrev)
    {
        _setupRole(ADMIN_ROLE, msg.sender);
        developer = msg.sender;
    }

    receive() external payable {}

    fallback() external payable {}

    function safeMintId(uint256 _id) external payable isSaleOpen {
        require(
            _id <= MAX_TOKENS_AMOUNT,
            "Collection: safeMintId::Mint token ID too above mint"
        );
        require(
            msg.value == TOKEN_PRICE,
            "Collection: safeMintId:: Please send the right amount of tokens!"
        );
        require(
            totalSupply() + 1 <= MAX_TOKENS_AMOUNT,
            "Collection: safeMintId:: Exceeding total supply limit!"
        );
        _safeMint(msg.sender, _id);
    }

    function airdrop() external onlyRole(ADMIN_ROLE) {
        for (uint256 i = 0; i < airdropAddresses.length - 1; i++) {
            _safeMint(airdropAddresses[i], totalSupply() + 1);
            emit Airdrop(airdropAddresses[i]);
        }

        delete airdropAddresses;
        require(airdropAddresses.length == 0);
    }

    function addAirdropAddresses(address[] memory _addresses)
        external
        onlyRole(ADMIN_ROLE)
    {
        airdropAddresses = _addresses;
    }

    function viewAirdropAddresses() external view returns (address[] memory) {
        return airdropAddresses;
    }

    function toggleSaleOn() public onlyRole(ADMIN_ROLE) {
        openSale = true;
        emit SaleStatus(true);
    }

    function toggleSaleOff() public onlyRole(ADMIN_ROLE) {
        openSale = false;
        emit SaleStatus(false);
    }

    // when developer = NFT creator
    function skimAll() external onlyRole(ADMIN_ROLE) {
        (bool success, ) = owner().call{value: address(this).balance}("");
        require(success, "Collection: withdrawFunds:: Transaction Failed!");

        emit Skimmed(owner(), address(this).balance);
    }

    function setBaseURI(string memory baseURI) public onlyRole(ADMIN_ROLE) {
        BASE_URI = baseURI;
        emit BaseUri(baseURI);
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
