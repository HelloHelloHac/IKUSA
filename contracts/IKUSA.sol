// SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ERC721A.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract IKUSA is Ownable, ERC721A, ReentrancyGuard {
    bytes32 public root;

    uint256 public privateSalePrice = 0.00005 ether;
    uint256 public publicSalePrice = 0.0005 ether;
    uint256 public maxPerAddressDuringMint = 2;
    bool public privateSaleState = false;
    bool public publicSaleState = false;

    constructor(bytes32 _root)
        ERC721A("IKUSA", "IKS", 100, 10000)
        ReentrancyGuard()
    {
        root = _root;
    }

    function privateMint(uint256 quantity, bytes32[] memory proof)
        external
        payable
        nonReentrant
    {
        require(
            isValid(proof, keccak256(abi.encodePacked(msg.sender))),
            "Not a WhiteListed Address"
        );
        require(
            _numberMinted(msg.sender) + quantity <= maxPerAddressDuringMint
        );
        require(
            totalSupply() + quantity <= 10000,
            "IKUSA: Mint Will exceed CollectionSize"
        );
        uint256 totalCost = privateSalePrice * quantity;

        require(msg.value >= totalCost, "Wrong Amount Sent");
        require(privateSaleState, "Sale Not Started");

        _safeMint(msg.sender, quantity);
    }

    function publicMint(uint256 quantity) external payable nonReentrant {
        require(
            totalSupply() + quantity <= 10000,
            "IKUSA: Mint Will exceed CollectionSize"
        );
        uint256 totalCost = privateSalePrice * quantity;

        require(msg.value >= totalCost, "Wrong Amount Sent");
        require(publicSaleState, "Sale Not Started");

        _safeMint(msg.sender, quantity);
    }

    function isValid(bytes32[] memory proof, bytes32 leaf)
        public
        view
        returns (bool)
    {
        return MerkleProof.verify(proof, root, leaf);
    }

    function changePrivateSale(bool _privateSale) public onlyOwner {
        privateSaleState = _privateSale;
    }

    function changePublicSale(bool _publicSale) public onlyOwner {
        publicSaleState = _publicSale;
    }

    // // metadata URI
    string private _baseTokenURI;

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function setBaseURI(string calldata baseURI) external onlyOwner {
        _baseTokenURI = baseURI;
    }

    function withdrawMoney() external onlyOwner {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "Transfer failed.");
    }
}
