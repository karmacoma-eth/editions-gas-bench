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

    function purchase(IEditionSingleMintable edition, address to) public payable {
        SingleEditionMintable(address(edition)).purchase{value: msg.value}();
        SingleEditionMintable(address(edition)).transferFrom(address(this), to, 1);
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
    SingleEditionMintableCreator editionCreator;

    IEditionSingleMintable edition;
    IEditionSingleMintable openEdition;
    IEditionSingleMintable openEditionForSale;
    IEditionSingleMintable openEditionForSaleByMinterContract;

    MinterContract minter;

    uint256 editionSize = 100;
    uint256 royaltyBPS = 1000;
    uint256 mintPeriodSeconds = 2 days;

    address[] batch10;

    bytes32 constant hash = keccak256("someHash");
    address bob = makeAddr("bob");

    /*//////////////////////////////////////////////////////////////
                                 SETUP
    //////////////////////////////////////////////////////////////*/

    function setUp() public {
        vm.deal(bob, 100 ether);
        minter = new MinterContract();

        editionImpl = new SingleEditionMintable(new SharedNFTLogic());
        editionCreator = new SingleEditionMintableCreator(address(editionImpl));
        edition = editionCreator.getEditionAtId(
            editionCreator.createEdition(
                "name", "symbol", "description", "animationUrl", hash, "imageUrl", hash, editionSize, royaltyBPS
            )
        );
        ApproveMinters(address(edition)).setApprovedMinter(address(minter), true);
        // pre-mint for tokenUri
        edition.mintEdition(address(this));

        openEdition = editionCreator.getEditionAtId(
            editionCreator.createEdition(
                "openEdition", "symbol", "description", "animationUrl", hash, "imageUrl", hash, editionSize, royaltyBPS
            )
        );
        ApproveMinters(address(openEdition)).setApprovedMinter(address(0), true);
        // transfer ownership to 0, so that calls coming from this contract don't come from the owner
        IERC173(address(openEdition)).transferOwnership(address(0xdead));

        openEditionForSale = editionCreator.getEditionAtId(
            editionCreator.createEdition(
                "openEditionForSale",
                "symbol",
                "description",
                "animationUrl",
                hash,
                "imageUrl",
                hash,
                editionSize,
                royaltyBPS
            )
        );
        ApproveMinters(address(openEditionForSale)).setApprovedMinter(address(0), true);
        SingleEditionMintable(address(openEditionForSale)).setSalePrice(1 ether);
        IERC173(address(openEditionForSale)).transferOwnership(address(0xdead));

        openEditionForSaleByMinterContract = editionCreator.getEditionAtId(
            editionCreator.createEdition(
                "openEditionForSaleByMinterContract",
                "symbol",
                "description",
                "animationUrl",
                hash,
                "imageUrl",
                hash,
                editionSize,
                royaltyBPS
            )
        );
        ApproveMinters(address(openEditionForSaleByMinterContract)).setApprovedMinter(address(minter), true);
        SingleEditionMintable(address(openEditionForSaleByMinterContract)).setSalePrice(1 ether);
        IERC173(address(openEditionForSaleByMinterContract)).transferOwnership(address(0xdead));

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

    /// mint to a fresh address (more expensive because of the 0->1 balance change)
    function testMintByOwner() public {
        edition.mintEdition(bob);
    }

    function testMintByContract() public {
        minter.mint(edition, bob);
    }

    function testMintOpenEdition() public {
        openEdition.mintEdition(bob);
    }

    function testPaidMintOpenEdition() public {
        vm.prank(bob);
        SingleEditionMintable(address(openEditionForSale)).purchase{value: 1 ether}();
    }

    function testPaidMintByContract() public {
        minter.purchase{value: 1 ether}(openEditionForSaleByMinterContract, bob);
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
