pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";


contract nftSample is ERC721{

    constructor()ERC721("smaple","samp"){}


    function minting(uint id)public {
        _safeMint(msg.sender,id);
    }
}