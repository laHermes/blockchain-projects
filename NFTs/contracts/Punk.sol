// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Punks is ERC721Enumerable, AccessControl, Ownable {
    event SaleStatus(bool indexed status);
    event Airdrop(address indexed account);
    event Skimmed(address indexed account, uint256 indexed amount);

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    uint256 public MAX_TOKENS_AMOUNT = 100;
    uint256 public TOKEN_PRICE = 0.01 ether;

    address public immutable artist;

    //if exist, make them immutable
    address public developer;
    address public marketing;

    string public BASE_URI =
        "https://enigmatic-mountain-59518.herokuapp.com/token/";

    bool public openSale = false;

    address[] public airdropAddresses;

    modifier isSaleOpen() {
        require(openSale, "Punk: Sale is closed!");
        _;
    }

    constructor(string memory _name, string memory _abbrev)
        ERC721(_name, _abbrev)
    {
        _setupRole(ADMIN_ROLE, msg.sender);
        artist = msg.sender;
    }

    receive() external payable {
        safeMint(msg.value, msg.sender);
    }

    fallback() external payable {}

    function tokenMint() external payable {
        safeMint(msg.value, msg.sender);
    }

    //!!!!!WARNING: EITHER REMOVE safeMint or safeMintId function!!!!

    function safeMint(uint256 _amount, address _to) private isSaleOpen {
        require(
            _amount == TOKEN_PRICE,
            "Punks: safeMint:: Please send the right amount of tokens!"
        );
        require(
            totalSupply() + 1 <= MAX_TOKENS_AMOUNT,
            "Punks: safeMint:: Exceeding total supply limit!"
        );
        _safeMint(_to, totalSupply() + 1);
    }

    function safeMintId(
        uint256 _amount,
        address _to,
        uint256 _id
    ) private isSaleOpen {
        require(
            _id <= MAX_TOKENS_AMOUNT,
            "Punks: safeMintId::Mint token ID too above mint"
        );
        require(
            _amount == TOKEN_PRICE,
            "Punks: safeMintId:: Please send the right amount of tokens!"
        );
        require(
            totalSupply() + 1 <= MAX_TOKENS_AMOUNT,
            "Punks: safeMintId:: Exceeding total supply limit!"
        );
        _safeMint(_to, _id);
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
        require(success, "Punks: withdrawFunds:: Transaction Failed!");

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
