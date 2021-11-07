// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// NFT contract to inherit from 
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

//Helper functions OpenZeppelin provides
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "hardhat/console.sol";

// Our contract inherits from ERC721, which is the standard NFT contract
contract MyEpicGame is ERC721 {

    struct CharacterAttributes {
        uint characterIndex;
        string name;
        string imageURI;
        uint hp;
        uint maxHp;
        uint attackDamage;
    }

    // The tokenId is the NFT unique identifier, which is just a number that goes
    //1,2,3 e.t.c
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // Little array to hold the default data for our characters
    CharacterAttributes[] defaultCharacters;

    // create a mapping from the NFT's tokenId => that NFTs attributes.
    mapping(uint256 => CharacterAttributes) public nftHolderAttributes;

    // mapping from an address => the NFT tokedId. Gives me an easy way to 
    //store the owner of the NFT and reference it later
    mapping(address => uint256) public nftHolders;


    constructor(
        string[] memory characterNames,
        string[] memory characterImageURIs,
        uint[] memory characterHp,
        uint[] memory characterAttackDmg
    )
        ERC721("Heroes", "HERO") 
    {
        // Loop through all the characters, and save their values in our contract 
        //so we can use them later when we mint our NFTs.
        for (uint256 i = 0; i < characterNames.length; i += 1) {
            defaultCharacters.push(CharacterAttributes({
                characterIndex: i,
                name: characterNames[i],
                imageURI: characterImageURIs[i],
                hp: characterHp[i],
                maxHp: characterHp[i],
                attackDamage: characterAttackDmg[i]
            }));

            CharacterAttributes memory c = defaultCharacters[i];
            console.log("Done initializing %s w/ HP %s, img %s", c.name, c.hp, c.imageURI);
        }

        // increment tokenIds here so that my first NFT has an ID of 1.
        _tokenIds.increment();
   }

   // Users will be able to hit this function and get their NFT based on the
   //characters they send in!
   function mintCharacterNFT(uint _characterIndex) external {
       // Get the current tokenId 
       uint256 newItemId = _tokenIds.current();

       // The magical function! Assigns the tokenId to the caller's wallet address
        _safeMint(msg.sender, newItemId);

       // We map the tokenId => their character attributes.
       nftHolderAttributes[newItemId] = CharacterAttributes({
           characterIndex: _characterIndex,
           name: defaultCharacters[_characterIndex].name,
           imageURI: defaultCharacters[_characterIndex].imageURI,
           hp: defaultCharacters[_characterIndex].hp,
           maxHp: defaultCharacters[_characterIndex].hp,
           attackDamage: defaultCharacters[_characterIndex].attackDamage
       });

       console.log("Minted NFT w/ tokenId %s and characterIndex %s", newItemId, _characterIndex);

       // keep an easy way to see who owns what NFT
       nftHolders[msg.sender] = newItemId;

       // Increment the tokenId for the next person that uses it
       _tokenIds.increment();
   }
}