// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {IERC721, IERC721Metadata} from "forge-std/interfaces/IERC721.sol";

import {IERC173} from "./shared/IERC173.sol";

import {Edition} from "showtime-nft-editions/Edition.sol";
import {EditionCreator} from "showtime-nft-editions/EditionCreator.sol";
import {IEdition} from "showtime-nft-editions/interfaces/IEdition.sol";

/*//////////////////////////////////////////////////////////////
                            HELPERS
//////////////////////////////////////////////////////////////*/

contract MinterContract {
    function mint(IEdition edition, address to) public payable {
        edition.mint{value: msg.value}(to);
    }

    function mintBatch(IEdition edition, address[] memory to) public {
        edition.mintBatch(to);
    }
}

contract ShowtimeEditions is Test {
    /*//////////////////////////////////////////////////////////////
                                 STATE
    //////////////////////////////////////////////////////////////*/

    Edition editionImpl;
    EditionCreator editionCreator;

    IEdition edition;
    IEdition openEdition;
    IEdition openEditionForSale;
    IEdition openEditionForSaleByMinterContract;

    MinterContract minter;

    uint256 editionSize = 100;
    uint256 royaltyBPS = 1000;
    uint256 mintPeriodSeconds = 2 days;

    address[] batch10;

    address bob = makeAddr("bob");

    /*//////////////////////////////////////////////////////////////
                                 SETUP
    //////////////////////////////////////////////////////////////*/

    function setUp() public {
        minter = new MinterContract();

        editionImpl = new Edition();
        editionCreator = new EditionCreator(address(editionImpl));

        edition = editionCreator.createEdition(
            "name", "symbol", "description", "animationUrl", "imageUrl", editionSize, royaltyBPS, mintPeriodSeconds
        );
        edition.setApprovedMinter(address(minter), true);
        // pre-mint for tokenUri
        edition.mint(address(this));

        openEdition = editionCreator.createEdition(
            "openEdition", "symbol", "description", "animationUrl", "imageUrl", 0, royaltyBPS, mintPeriodSeconds
        );
        openEdition.setApprovedMinter(address(0), true);
        // transfer ownership to 0, so that calls coming from this contract don't come from the owner
        IERC173(address(openEdition)).transferOwnership(address(0));

        openEditionForSale = editionCreator.createEdition(
            "openEditionForSale", "symbol", "description", "animationUrl", "imageUrl", 0, royaltyBPS, mintPeriodSeconds
        );
        openEditionForSale.setApprovedMinter(address(0), true);
        openEditionForSale.setSalePrice(1 ether);
        IERC173(address(openEditionForSale)).transferOwnership(address(0));

        openEditionForSaleByMinterContract = editionCreator.createEdition(
            "openEditionForSaleByMinterContract",
            "symbol",
            "description",
            "animationUrl",
            "imageUrl",
            0,
            royaltyBPS,
            mintPeriodSeconds
        );
        openEditionForSaleByMinterContract.setApprovedMinter(address(minter), true);
        openEditionForSaleByMinterContract.setSalePrice(1 ether);
        IERC173(address(openEditionForSaleByMinterContract)).transferOwnership(address(0));

        for (uint160 i = 0; i < 10; i++) {
            batch10.push(address(i + 1));
        }
    }

    /*//////////////////////////////////////////////////////////////
                               GAS TESTS
    //////////////////////////////////////////////////////////////*/

    function testCreateNewEdition() public {
        editionCreator.createEdition(
            "new name", "symbol", "description", "animationUrl", "imageUrl", editionSize, royaltyBPS, mintPeriodSeconds
        );
    }

    function testMintByOwner() public {
        edition.mint(bob);
    }

    function testMintByContract() public {
        minter.mint(edition, bob);
    }

    function testMintOpenEdition() public {
        openEdition.mint(bob);
    }

    function testMint10ByOwner() public {
        edition.mintBatch(batch10);
    }

    function testMint10ByContract() public {
        minter.mintBatch(edition, batch10);
    }

    function testMint10OpenEdition() public {
        openEdition.mintBatch(batch10);
    }

    function testPaidMintOpenEdition() public {
        openEditionForSale.mint{value: 1 ether}(bob);
    }

    function testPaidMintByContract() public {
        minter.mint{value: 1 ether}(openEditionForSaleByMinterContract, bob);
    }

    function testTokenURI() public view {
        IERC721Metadata(address(edition)).tokenURI(1);
    }

    function testContractURI() public view {
        edition.contractURI();
    }

    function testTransferFrom() public {
        IERC721(address(edition)).transferFrom(address(this), address(1), 1);
    }
}
