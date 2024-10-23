// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {IERC721A} from "@erc721a/contracts/IERC721A.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

import {ERC721A__IERC721Receiver} from "@erc721a/contracts/ERC721A.sol";

import {DeployERC721ABasic} from "script/deployment/DeployERC721ABasic.s.sol";
import {ERC721ABasic, ERC721ACore} from "src/examples/ERC721ABasic.sol";
import {HelperConfig} from "script/helpers/HelperConfig.s.sol";
import {TestHelper} from "test/utils/TestHelper.sol";

contract ERC721ACoreUnitTest is Test {
    /*//////////////////////////////////////////////////////////////
                             CONFIGURATION
    //////////////////////////////////////////////////////////////*/
    DeployERC721ABasic deployer;
    HelperConfig helperConfig;
    HelperConfig.NetworkConfig networkConfig;

    /*//////////////////////////////////////////////////////////////
                               CONTRACTS
    //////////////////////////////////////////////////////////////*/
    ERC721ABasic nftBasic;
    ERC20Mock token;

    /*//////////////////////////////////////////////////////////////
                                HELPERS
    //////////////////////////////////////////////////////////////*/
    address USER = makeAddr("user");
    uint256 constant NEW_BATCH_LIMIT = 20;
    uint256 constant NEW_MAX_WALLET_SIZE = 20;

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/
    event BatchLimitSet(address indexed sender, uint256 batchLimit);
    event MaxWalletSizeSet(address indexed sender, uint256 maxWalletSize);
    event BaseURIUpdated(address indexed sender, string indexed baseUri);
    event ContractURIUpdated(address indexed sender, string indexed contractUri);
    event RoyaltyUpdated(address indexed feeAddress, uint96 indexed royaltyNumerator);
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /*//////////////////////////////////////////////////////////////
                               MODIFIERS
    //////////////////////////////////////////////////////////////*/
    modifier skipFork() {
        if (block.chainid != 31337) {
            return;
        }
        _;
    }

    modifier noBatchLimit() {
        address owner = nftBasic.owner();
        vm.prank(owner);
        nftBasic.setBatchLimit(100);
        _;
    }

    modifier noMaxWallet() {
        address owner = nftBasic.owner();
        vm.prank(owner);
        nftBasic.setMaxWalletSize(0);
        _;
    }

    /*//////////////////////////////////////////////////////////////
                                 SETUP
    //////////////////////////////////////////////////////////////*/
    function setUp() external virtual {
        deployer = new DeployERC721ABasic();
        (nftBasic, helperConfig) = deployer.run();

        networkConfig = helperConfig.getActiveNetworkConfigStruct();

        token = new ERC20Mock();
    }

    /*//////////////////////////////////////////////////////////////
                          TEST   INITIALIZATION
    //////////////////////////////////////////////////////////////*/
    function test__ERC721ACore__Initialization() public {
        assertEq(nftBasic.getMaxSupply(), networkConfig.args.coreConfig.maxSupply);

        assertEq(nftBasic.getBaseURI(), networkConfig.args.coreConfig.baseURI);
        assertEq(nftBasic.contractURI(), networkConfig.args.coreConfig.contractURI);

        assertEq(nftBasic.getMaxWalletSize(), networkConfig.args.coreConfig.maxWalletSize);
        assertEq(nftBasic.getBatchLimit(), networkConfig.args.coreConfig.batchLimit);

        assertEq(nftBasic.supportsInterface(0x80ac58cd), true); // ERC721
        assertEq(nftBasic.supportsInterface(0x2a55205a), true); // ERC2981

        vm.expectRevert(IERC721A.URIQueryForNonexistentToken.selector);
        nftBasic.tokenURI(1);
    }

    /*//////////////////////////////////////////////////////////////
                            TEST DEPLOYMENT
    //////////////////////////////////////////////////////////////*/
    function test__ERC721ACore__RevertWhen__NoBaseURI() public {
        HelperConfig.ConstructorArguments memory args = networkConfig.args;

        args.coreConfig.baseURI = "";

        vm.expectRevert(ERC721ACore.ERC721ACore_NoBaseURI.selector);
        new ERC721ABasic(args.coreConfig);
    }

    /*//////////////////////////////////////////////////////////////
                             TEST ROYALTIES
    //////////////////////////////////////////////////////////////*/
    function test__ERC721ACore__InitialRoyalties() public view {
        uint256 salePrice = 100;
        (address feeAddress, uint256 royaltyAmount) = nftBasic.royaltyInfo(1, salePrice);
        assertEq(feeAddress, networkConfig.args.coreConfig.owner);
        assertEq(royaltyAmount, (500 * 100) / 10000);
    }

    /*//////////////////////////////////////////////////////////////
                        TEST SET MAXWALLETSIZE
    //////////////////////////////////////////////////////////////*/
    function test__ERC721ACore__SetMaxWalletSize() public {
        address owner = nftBasic.owner();
        vm.prank(owner);
        nftBasic.setMaxWalletSize(NEW_MAX_WALLET_SIZE);
        assertEq(nftBasic.getMaxWalletSize(), NEW_MAX_WALLET_SIZE);
    }

    function test__ERC721ACore__EmitEvent__SetMaxWalletSize() public {
        address owner = nftBasic.owner();

        vm.expectEmit(true, true, true, true);
        emit MaxWalletSizeSet(owner, NEW_MAX_WALLET_SIZE);

        vm.prank(owner);
        nftBasic.setMaxWalletSize(NEW_MAX_WALLET_SIZE);
    }

    function test__ERC721ACore__RevertWhen__NotOwnerSetsMaxWalletSize() public {
        vm.prank(USER);

        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, USER));
        nftBasic.setMaxWalletSize(NEW_MAX_WALLET_SIZE);
    }

    /*//////////////////////////////////////////////////////////////
                           TEST SET BATCHLIMIT
    //////////////////////////////////////////////////////////////*/
    function test__ERC721ACore__SetBatchLimit() public {
        address owner = nftBasic.owner();
        vm.prank(owner);
        nftBasic.setBatchLimit(NEW_BATCH_LIMIT);
        assertEq(nftBasic.getBatchLimit(), NEW_BATCH_LIMIT);
    }

    function test__ERC721ACore__EmitEvent__SetBatchLimit() public {
        address owner = nftBasic.owner();

        vm.expectEmit(true, true, true, true);
        emit BatchLimitSet(owner, NEW_BATCH_LIMIT);

        vm.prank(owner);
        nftBasic.setBatchLimit(NEW_BATCH_LIMIT);
    }

    function test__ERC721ACore__RevertWhen__BatchLimitTooHigh() public {
        address owner = nftBasic.owner();
        vm.prank(owner);

        vm.expectRevert(ERC721ACore.ERC721ACore_BatchLimitTooHigh.selector);
        nftBasic.setBatchLimit(101);
    }

    function test__ERC721ACore__RevertWhen__NotOwnerSetsBatchLimit() public {
        vm.prank(USER);

        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, USER));
        nftBasic.setBatchLimit(NEW_BATCH_LIMIT);
    }

    /*//////////////////////////////////////////////////////////////
                            TEST WITHDRAW ETH
    //////////////////////////////////////////////////////////////*/
    function test__ERC721ACore__WithdrawETH() public {
        deal(address(nftBasic), 1 ether);
        uint256 contractBalance = address(nftBasic).balance;
        assertGt(contractBalance, 0);

        uint256 initialBalance = nftBasic.owner().balance;

        vm.startPrank(nftBasic.owner());
        nftBasic.withdrawETH(nftBasic.owner());
        vm.stopPrank();

        uint256 newBalance = nftBasic.owner().balance;
        assertEq(address(nftBasic).balance, 0);
        assertEq(newBalance, initialBalance + contractBalance);
    }

    function test__ERC721ACore__RevertsWhen__EthTransferFails() public {
        uint256 amount = 1 ether;
        deal(address(nftBasic), amount);

        uint256 contractBalance = address(nftBasic).balance;
        assertGt(contractBalance, 0);

        address owner = nftBasic.owner();

        vm.mockCallRevert(owner, amount, "", "");

        vm.expectRevert(ERC721ACore.ERC721ACore_EthTransferFailed.selector);
        vm.prank(owner);
        nftBasic.withdrawETH(owner);
    }

    function test__ERC721ACore__RevertWhen__NotOwnerWithdrawsETH() public {
        deal(address(nftBasic), 1 ether);
        address owner = nftBasic.owner();
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, USER));

        vm.prank(USER);
        nftBasic.withdrawETH(owner);
    }

    /*//////////////////////////////////////////////////////////////
                          TEST WITHDRAW TOKENS
    //////////////////////////////////////////////////////////////*/
    function test__ERC721ACore__WithdrawTokens() public {
        token.mint(address(nftBasic), 1000 ether);

        uint256 contractBalance = token.balanceOf(address(nftBasic));
        assertGt(contractBalance, 0);

        uint256 initialBalance = token.balanceOf(nftBasic.owner());

        vm.startPrank(nftBasic.owner());
        nftBasic.withdrawTokens(address(token), nftBasic.owner());
        vm.stopPrank();

        uint256 newBalance = token.balanceOf(nftBasic.owner());
        assertEq(token.balanceOf(address(nftBasic)), 0);
        assertEq(newBalance, initialBalance + contractBalance);
    }

    function test__ERC721ACore__RevertsWhen__TokenTransferFails() public {
        uint256 amount = 1000 ether;
        token.mint(address(nftBasic), amount);

        uint256 contractBalance = token.balanceOf(address(nftBasic));
        assertGt(contractBalance, 0);

        address owner = nftBasic.owner();

        vm.mockCall(address(token), abi.encodeWithSelector(token.transfer.selector, owner, amount), abi.encode(false));

        vm.expectRevert(ERC721ACore.ERC721ACore_TokenTransferFailed.selector);
        vm.prank(owner);
        nftBasic.withdrawTokens(address(token), owner);
    }

    function test__ERC721ACore__RevertWhen__NotOwnerWithdrawsTokens() public {
        token.mint(address(nftBasic), 1000 ether);

        address owner = nftBasic.owner();
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, USER));

        vm.prank(USER);
        nftBasic.withdrawTokens(address(token), owner);
    }

    /*//////////////////////////////////////////////////////////////
                          TEST SET CONTRACTURI
    //////////////////////////////////////////////////////////////*/
    function test__ERC721ACore__SetContractURI() public {
        address owner = nftBasic.owner();
        string memory newContractURI = "new-contract-uri/";

        vm.prank(owner);
        nftBasic.setContractURI(newContractURI);

        assertEq(nftBasic.getContractURI(), newContractURI);
    }

    function test__ERC721ACore__EmitEvent__SetContractURI() public {
        address owner = nftBasic.owner();
        string memory newContractURI = "new-contract-uri/";

        vm.expectEmit(true, true, true, true);
        emit ContractURIUpdated(owner, newContractURI);

        vm.prank(owner);
        nftBasic.setContractURI(newContractURI);
    }

    function test__ERC721ACore__RevertWhen__NotOwnerSetsContractURI() public {
        string memory newContractURI = "new-contract-uri/";
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, USER));

        vm.prank(USER);
        nftBasic.setContractURI(newContractURI);
    }

    /*//////////////////////////////////////////////////////////////
                            TEST SET BASEURI
    //////////////////////////////////////////////////////////////*/
    function test__ERC721ACore__SetBaseURI() public {
        address owner = nftBasic.owner();
        string memory newBaseURI = "new-base-uri/";

        vm.prank(owner);
        nftBasic.setBaseURI(newBaseURI);

        assertEq(nftBasic.getBaseURI(), newBaseURI);
    }

    function test__ERC721ACore__EmitEvent__SetBaseURI() public {
        address owner = nftBasic.owner();
        string memory newBaseURI = "new-base-uri/";

        vm.expectEmit(true, true, true, true);
        emit BaseURIUpdated(owner, newBaseURI);

        vm.prank(owner);
        nftBasic.setBaseURI(newBaseURI);
    }

    function test__ERC721ACore__RevertWhen__NotOwnerSetsBaseURI() public {
        string memory newBaseURI = "new-base-uri/";
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, USER));

        vm.prank(USER);
        nftBasic.setBaseURI(newBaseURI);
    }

    /*//////////////////////////////////////////////////////////////
                            TEST SET ROYALTY
    //////////////////////////////////////////////////////////////*/
    function test__ERC721ACore__SetRoyalty() public {
        address owner = nftBasic.owner();
        uint96 newRoyalty = 1000;

        vm.prank(owner);
        nftBasic.setRoyalty(USER, newRoyalty);

        uint256 salePrice = 100;
        (address feeAddress, uint256 royaltyAmount) = nftBasic.royaltyInfo(0, salePrice);
        assertEq(feeAddress, USER);
        assertEq(royaltyAmount, 10);
    }

    function test__ERC721ACore__EmitEvent__SetRoyalty() public {
        uint96 newRoyalty = 1000;
        address owner = nftBasic.owner();

        vm.expectEmit(true, true, true, true);
        emit RoyaltyUpdated(USER, newRoyalty);

        vm.prank(owner);
        nftBasic.setRoyalty(USER, newRoyalty);
    }

    function test__ERC721ACore__RevertWhen__NotOwnerSetsRoyalty() public {
        uint96 newRoyalty = 1000;
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, USER));

        vm.prank(USER);
        nftBasic.setRoyalty(USER, newRoyalty);
    }

    /*//////////////////////////////////////////////////////////////
                               TEST MINT
    //////////////////////////////////////////////////////////////*/

    /// SUCCESS
    //////////////////////////////////////////////////////////////*/
    function test__ERC721ACore__Mint(uint256 quantity) public skipFork {
        quantity = bound(quantity, 1, nftBasic.getBatchLimit());

        vm.prank(USER);
        nftBasic.mint(quantity);

        assertEq(nftBasic.balanceOf(USER), quantity);
    }

    function test__ERC721ACore__MintNoMaxWallet(uint256 quantity) public noMaxWallet noBatchLimit skipFork {
        quantity = bound(quantity, 1, nftBasic.getMaxSupply());

        uint256 batchLimit = nftBasic.getBatchLimit();

        if (quantity % batchLimit > 0) {
            vm.prank(USER);
            nftBasic.mint(quantity % batchLimit);
        }
        if (quantity >= batchLimit) {
            for (uint256 index = 0; index < quantity / batchLimit; index++) {
                vm.prank(USER);
                nftBasic.mint(batchLimit);
            }
        }

        assertEq(nftBasic.balanceOf(USER), quantity);
    }

    /// EVENT EMITTED
    //////////////////////////////////////////////////////////////*/
    function test__ERC721ACore__EmitEvent__Mint() public {
        vm.expectEmit(true, true, true, true);
        emit Transfer(address(0), USER, 1);

        vm.prank(USER);
        nftBasic.mint(1);
    }

    /// REVERTS
    //////////////////////////////////////////////////////////////*/
    function test__ERC721ACore__RevertWhen__InsufficientMintQuantity() public {
        vm.expectRevert(IERC721A.MintZeroQuantity.selector);
        vm.prank(USER);
        nftBasic.mint(0);
    }

    function test__ERC721ACore__RevertWhen__MintExceedsBatchLimit() public {
        uint256 quantity = nftBasic.getBatchLimit() + 1;

        vm.expectRevert(ERC721ACore.ERC721ACore_ExceedsBatchLimit.selector);
        vm.prank(USER);
        nftBasic.mint(quantity);
    }

    function test__ERC721ACore__RevertWhen__MintExceedsMaxWalletSize() public {
        uint256 quantity = nftBasic.getMaxWalletSize() + 1;

        address owner = nftBasic.owner();
        vm.prank(owner);
        nftBasic.setBatchLimit(quantity);

        vm.expectRevert(ERC721ACore.ERC721ACore_ExceedsMaxPerWallet.selector);
        vm.prank(USER);
        nftBasic.mint(quantity);
    }

    function test__ERC721ACore__RevertWhen__MaxSupplyExceeded() public {
        uint256 maxSupply = nftBasic.getMaxSupply();

        for (uint256 index = 0; index < maxSupply; index++) {
            vm.prank(USER);
            nftBasic.mint(1);
        }

        vm.expectRevert(ERC721ACore.ERC721ACore_ExceedsMaxSupply.selector);
        vm.prank(USER);
        nftBasic.mint(1);
    }

    /*//////////////////////////////////////////////////////////////
                             TEST TRANSFER
    //////////////////////////////////////////////////////////////*/
    function test__ERC721ACore__Transfer(address account, address receiver) public skipFork {
        uint256 quantity = 1;
        vm.assume(account != address(0) && account.code.length == 0);
        vm.assume(receiver != address(0) && receiver.code.length == 0);

        vm.prank(account);
        nftBasic.mint(quantity);

        assertEq(nftBasic.balanceOf(account), quantity);
        assertEq(nftBasic.ownerOf(1), account);

        vm.prank(account);
        nftBasic.transferFrom(account, receiver, 1);

        assertEq(nftBasic.ownerOf(1), receiver);
        assertEq(nftBasic.balanceOf(receiver), quantity);
    }

    /*//////////////////////////////////////////////////////////////
                             TEST TOKENURI
    //////////////////////////////////////////////////////////////*/
    function test__ERC721ACore__RetrieveTokenUri() public {
        vm.prank(USER);
        nftBasic.mint(1);

        assertEq(nftBasic.tokenURI(1), string.concat(networkConfig.args.coreConfig.baseURI, "1"));
    }

    function test__ERC721ACore__UniqueLinearTokenURI() public {
        TestHelper testHelper = new TestHelper();

        uint256 maxSupply = nftBasic.getMaxSupply();

        vm.startPrank(USER);
        for (uint256 index = 1; index <= maxSupply; index++) {
            nftBasic.mint(1);
            assertEq(testHelper.isTokenUriSet(nftBasic.tokenURI(index)), false);
            console.log(nftBasic.tokenURI(index));
            testHelper.setTokenUri(nftBasic.tokenURI(index));
        }
        vm.stopPrank();
    }
}
