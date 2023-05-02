pragma solidity ^0.8.0;


import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/IERC721.sol";

contract Airdrop{

    struct NftAirdrop{
        address nftAddress;
        uint id;
    }

    uint totalNftAirdropsCount;
    uint nextNftAirdrop;

    mapping(address => bool)addressIsContributor;
    mapping(address => bool)notEligibleAddress;
    mapping(address=>uint)public addressToIndexContributor;

    address[]public contributorAddress;
    NftAirdrop[]private totalNftAirdrops;

    address admin;


    modifier onlyAdmin(){
        require(msg.sender == admin , "your not the admin");
        _;
    }

    modifier onlyNewContributors(){
        require(addressIsContributor[msg.sender] == false , "already a contributor");
        _;
    }

    modifier onlyContributor{
        require(addressIsContributor[msg.sender] == true , "already a contributor");
        _;
    }

    modifier isContributor(address _addr){
        require(addressIsContributor[_addr] == true , "already a contributor");
        _;
    }

    modifier isEligible(){
        require(notEligibleAddress[msg.sender] == false , "address is not eligible for Airdrop");
        _;
    }

    

    constructor(){
        admin = msg.sender;
    }

    function addForAirdrop(address []memory _addresses)public onlyAdmin{
        uint totalcontributors = contributorAddress.length;

        for(uint i = 0 ; i<_addresses.length ; i++){
            require(addressIsContributor[_addresses[i]] == false,"one of the addresses is eligible");

            contributorAddress.push(_addresses[i]);

            addressToIndexContributor[_addresses[i]] = totalcontributors;

            addressIsContributor[_addresses[i]] = true;

            totalcontributors++;
        }
    }

    function setAirdropNfts(NftAirdrop memory nft)public onlyAdmin{
        address nftAddress = nft.nftAddress;

        require(IERC721(nftAddress).balanceOf(admin)> 0,"not enough tokens");

        totalNftAirdrops.push(nft);

        totalNftAirdropsCount++;
    }

    function setGroupNftAirdrops(NftAirdrop [] memory nfts)public onlyAdmin{

        for(uint i = 0 ; i<nfts.length ; i++){

        address nftAddress = nfts[i].nftAddress;

        require(IERC721(nftAddress).balanceOf(admin)> 0,"not enough tokens");

        totalNftAirdrops.push(nfts[i]);

        totalNftAirdropsCount++;
        }
    }


    function sendAirdrop()public onlyAdmin{
        require(contributorAddress.length <= totalNftAirdropsCount ,"not enough nfts");

        for(uint i = 0 ; i < contributorAddress.length ; i++){
            IERC721(totalNftAirdrops[i].nftAddress).transferFrom(msg.sender,contributorAddress[i],totalNftAirdrops[i].id);
        }
    }

    function removeContributor(address _address)public onlyAdmin isContributor(_address){
        uint indx = addressToIndexContributor[_address];

        uint contributorCount =  contributorAddress.length;
        uint lastIndx = contributorAddress.length -1;

        if(contributorCount == 0){
            contributorAddress.pop();

            delete addressToIndexContributor[_address];
        }

        if(contributorCount - 1 == indx){
            contributorAddress.pop();

            delete addressToIndexContributor[_address];

        }else{
            contributorAddress[indx] = contributorAddress[lastIndx];

            addressToIndexContributor[_address] = addressToIndexContributor[contributorAddress[lastIndx]];

            delete addressToIndexContributor[contributorAddress[lastIndx]];

            contributorAddress.pop();
        }
        addressIsContributor[_address] = false;

        notEligibleAddress[_address] = true;

    }

    function setContributor()public onlyNewContributors isEligible{
        require(contributorAddress.length <= totalNftAirdropsCount ,"not enough nfts");

        uint totalcontributors = contributorAddress.length;

        contributorAddress.push(msg.sender);

        addressToIndexContributor[msg.sender] = totalcontributors;

        addressIsContributor[msg.sender] = true;
    }
}