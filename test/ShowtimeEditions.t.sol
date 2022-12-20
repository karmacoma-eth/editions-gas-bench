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
    function mint(IEdition edition, address to) public {
        edition.mint(to);
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
    IEdition edition;
    IEdition openEdition;
    EditionCreator editionCreator;

    MinterContract minter;

    uint256 editionSize = 100;
    uint256 royaltyBPS = 1000;
    uint256 mintPeriodSeconds = 2 days;

    address[] batch10;

    /*//////////////////////////////////////////////////////////////
                                 SETUP
    //////////////////////////////////////////////////////////////*/

    function setUp() public {
        editionImpl = new Edition();
        editionCreator = new EditionCreator(address(editionImpl));
        edition = editionCreator.createEdition(
            "name", "symbol", "description", "animationUrl", "imageUrl", editionSize, royaltyBPS, mintPeriodSeconds
        );

        openEdition = editionCreator.createEdition(
            "openEdition", "symbol", "description", "animationUrl", "imageUrl", 0, royaltyBPS, mintPeriodSeconds
        );

        minter = new MinterContract();
        edition.setApprovedMinter(address(minter), true);

        openEdition.setApprovedMinter(address(0), true);

        // transfer ownership to 0, so that calls coming from this contract don't come from the owner
        IERC173(address(openEdition)).transferOwnership(address(0));

        edition.mint(address(this));

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
        edition.mint(address(this));
    }

    function testMintByContract() public {
        minter.mint(edition, address(this));
    }

    function testMintOpenEdition() public {
        openEdition.mint(address(this));
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
