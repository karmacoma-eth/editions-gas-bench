// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";

import "forge-std/Test.sol";
import {IERC721, IERC721Metadata} from "forge-std/interfaces/IERC721.sol";

import {IERC173} from "./shared/IERC173.sol";

import {SharedNFTLogic} from "zora-nft-editions/SharedNFTLogic.sol";
import {SingleEditionMintable} from "zora-nft-editions/SingleEditionMintable.sol";
import {SingleEditionMintableCreator} from "zora-nft-editions/SingleEditionMintableCreator.sol";
import {IEditionSingleMintable} from "zora-nft-editions/IEditionSingleMintable.sol";

/*//////////////////////////////////////////////////////////////
                            HELPERS
//////////////////////////////////////////////////////////////*/

interface ApproveMinters {
    function setApprovedMinter(address minter, bool approved) external;
}

contract MinterContract {
    function mint(IEditionSingleMintable edition, address to) public {
        edition.mintEdition(to);
    }

    function mintBatch(IEditionSingleMintable edition, address[] memory to) public {
        edition.mintEditions(to);
    }
}

contract ZoraEditions is Test {
    /*//////////////////////////////////////////////////////////////
                                 STATE
    //////////////////////////////////////////////////////////////*/

    SingleEditionMintable editionImpl;
    IEditionSingleMintable edition;
    IEditionSingleMintable openEdition;
    SingleEditionMintableCreator editionCreator;

    MinterContract minter;

    uint256 editionSize = 100;
    uint256 royaltyBPS = 1000;
    uint256 mintPeriodSeconds = 2 days;

    address[] batch10;

    bytes32 constant hash = keccak256("someHash");

    /*//////////////////////////////////////////////////////////////
                                 SETUP
    //////////////////////////////////////////////////////////////*/

    function setUp() public {
        editionImpl = new SingleEditionMintable(new SharedNFTLogic());
        editionCreator = new SingleEditionMintableCreator(address(editionImpl));
        edition = editionCreator.getEditionAtId(
            editionCreator.createEdition(
                "name", "symbol", "description", "animationUrl", hash, "imageUrl", hash, editionSize, royaltyBPS
            )
        );

        openEdition = editionCreator.getEditionAtId(
            editionCreator.createEdition(
                "openEdition", "symbol", "description", "animationUrl", hash, "imageUrl", hash, editionSize, royaltyBPS
            )
        );

        minter = new MinterContract();
        ApproveMinters(address(edition)).setApprovedMinter(address(minter), true);

        ApproveMinters(address(openEdition)).setApprovedMinter(address(0), true);

        // transfer ownership to 0, so that calls coming from this contract don't come from the owner
        IERC173(address(openEdition)).transferOwnership(address(0xdead));

        edition.mintEdition(address(this));

        for (uint160 i = 0; i < 10; i++) {
            batch10.push(address(i + 1));
        }
    }

    /*//////////////////////////////////////////////////////////////
                               GAS TESTS
    //////////////////////////////////////////////////////////////*/

    function testCreateNewEdition() public {
        editionCreator.createEdition(
            "name", "symbol", "description", "animationUrl", hash, "imageUrl", hash, editionSize, royaltyBPS
        );
    }

    function testMintByOwner() public {
        edition.mintEdition(address(this));
    }

    function testMintByContract() public {
        minter.mint(edition, address(this));
    }

    function testMintOpenEdition() public {
        openEdition.mintEdition(address(this));
    }

    function testMint10ByOwner() public {
        edition.mintEditions(batch10);
    }

    function testMint10ByContract() public {
        minter.mintBatch(edition, batch10);
    }

    function testMint10OpenEdition() public {
        openEdition.mintEditions(batch10);
    }

    function testTokenURI() public view {
        IERC721Metadata(address(edition)).tokenURI(1);
    }

    function testContractURI() public view {
        // not supported
        // edition.contractURI();
    }

    function testTransferFrom() public {
        IERC721(address(edition)).transferFrom(address(this), address(1), 1);
    }
}
