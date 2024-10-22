// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import {IERC20Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721A} from "@erc721a/contracts/IERC721A.sol";

import {DeployERC721AFeeHandler} from "script/deployment/DeployERC721AFeeHandler.s.sol";
import {ERC721AFeeHandler} from "src/examples/ERC721AFeeHandler.sol";
import {FeeHandler} from "src/extensions/FeeHandler.sol";
import {HelperConfig} from "script/helpers/HelperConfig.s.sol";

contract ERC721AFeeHandlerUnitTest is Test {
    /*//////////////////////////////////////////////////////////////
                             CONFIGURATION
    //////////////////////////////////////////////////////////////*/
    DeployERC721AFeeHandler deployer;
    HelperConfig helperConfig;
    HelperConfig.NetworkConfig networkConfig;

    /*//////////////////////////////////////////////////////////////
                               CONTRACTS
    //////////////////////////////////////////////////////////////*/
    ERC721AFeeHandler nftContract;
    ERC20Mock token;

    /*//////////////////////////////////////////////////////////////
                                HELPERS
    //////////////////////////////////////////////////////////////*/
    address USER = makeAddr("user");
    uint256 constant STARTING_BALANCE = 500_000_000 ether;
    address NEW_FEE_ADDRESS = makeAddr("fee");
    uint256 constant NEW_FEE = 0.001 ether;

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/
    event EthFeeSet(address indexed sender, uint256 indexed fee);
    event TokenFeeSet(address indexed sender, uint256 indexed fee);
    event FeeAddressSet(address indexed sender, address indexed feeAddress);

    /*//////////////////////////////////////////////////////////////
                                 MODIFIERS
    //////////////////////////////////////////////////////////////*/
    modifier skipFork() {
        if (block.chainid != 31337) {
            return;
        }
        _;
    }

    modifier funded(address account) {
        // fund user with eth
        deal(account, 1000 ether);

        // fund user with tokens
        token.mint(account, STARTING_BALANCE);

        _;
    }
    /*//////////////////////////////////////////////////////////////
                                 SETUP
    //////////////////////////////////////////////////////////////*/

    function setUp() external virtual {
        deployer = new DeployERC721AFeeHandler();
        (nftContract, helperConfig) = deployer.run();

        networkConfig = helperConfig.getActiveNetworkConfigStruct();

        token = ERC20Mock(nftContract.getFeeToken());
    }

    function fund(address account) public {
        // fund user with eth
        deal(account, 10000 ether);

        // fund user with tokens
        token.mint(account, STARTING_BALANCE);
    }

    /*//////////////////////////////////////////////////////////////
                          TEST   INITIALIZATION
    //////////////////////////////////////////////////////////////*/
    function test__ERC721AFeeHandler__Initialization() public {
        assertEq(nftContract.getFeeAddress(), networkConfig.args.feeAddress);
        assertEq(nftContract.getFeeToken(), networkConfig.args.tokenAddress);

        assertEq(nftContract.getEthFee(), networkConfig.args.ethFee);
        assertEq(nftContract.getTokenFee(), networkConfig.args.tokenFee);

        assertEq(nftContract.getMaxWalletSize(), 10);
        assertEq(nftContract.getBatchLimit(), 10);

        vm.expectRevert(IERC721A.URIQueryForNonexistentToken.selector);
        nftContract.tokenURI(1);
    }

    /*//////////////////////////////////////////////////////////////
                            TEST DEPLOYMENT
    //////////////////////////////////////////////////////////////*/
    function test__ERC721AFeeHandler__RevertWhen__ZeroFeeAddress() public {
        HelperConfig.ConstructorArguments memory args = networkConfig.args;

        args.feeAddress = address(0);
        //ERC2981InvalidDefaultRoyaltyReceiver
        vm.expectRevert(FeeHandler.FeeHandler_FeeAddressIsZeroAddress.selector);
        new ERC721AFeeHandler(args.coreConfig, args.feeAddress, args.tokenAddress, args.tokenFee, args.ethFee);
    }

    /*//////////////////////////////////////////////////////////////
                           TEST SET FEEADDRESS
    //////////////////////////////////////////////////////////////*/
    function test__ERC721AFeeHandler__SetEthFeeAddress() public {
        address owner = nftContract.owner();
        vm.prank(owner);
        nftContract.setFeeAddress(NEW_FEE_ADDRESS);
        assertEq(nftContract.getFeeAddress(), NEW_FEE_ADDRESS);
    }

    function test__ERC721AFeeHandler__EmitEvent__SetEthFeeAddress() public {
        address owner = nftContract.owner();

        vm.expectEmit(true, true, true, true);
        emit FeeAddressSet(owner, NEW_FEE_ADDRESS);

        vm.prank(owner);
        nftContract.setFeeAddress(NEW_FEE_ADDRESS);
    }

    function test__ERC721AFeeHandler__RevertWhen__FeeAddressIsZero() public {
        address owner = nftContract.owner();
        vm.prank(owner);

        vm.expectRevert(FeeHandler.FeeHandler_FeeAddressIsZeroAddress.selector);
        nftContract.setFeeAddress(address(0));
    }

    function test__ERC721AFeeHandler__RevertWhen__NotOwnerSetsFeeAddress() public {
        vm.prank(USER);

        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, USER));
        nftContract.setFeeAddress(NEW_FEE_ADDRESS);
    }

    /*//////////////////////////////////////////////////////////////
                             TEST SET ETHFEE
    //////////////////////////////////////////////////////////////*/
    function test__ERC721AFeeHandler__SetEthFee() public {
        address owner = nftContract.owner();
        vm.prank(owner);
        nftContract.setEthFee(NEW_FEE);
        assertEq(nftContract.getEthFee(), NEW_FEE);
    }

    function test__ERC721AFeeHandler__EmitEvent__SetEthFee() public {
        address owner = nftContract.owner();

        vm.expectEmit(true, true, true, true);
        emit EthFeeSet(owner, NEW_FEE);

        vm.prank(owner);
        nftContract.setEthFee(NEW_FEE);
    }

    function test__ERC721AFeeHandler__RevertWhen__NotOwnerSetsEthFee() public {
        vm.prank(USER);

        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, USER));
        nftContract.setEthFee(NEW_FEE);
    }

    /*//////////////////////////////////////////////////////////////
                            TEST SET TOKENFEE
    //////////////////////////////////////////////////////////////*/
    function test__ERC721AFeeHandler__SetTokenFee() public {
        address owner = nftContract.owner();
        vm.prank(owner);
        nftContract.setTokenFee(NEW_FEE);
        assertEq(nftContract.getTokenFee(), NEW_FEE);
    }

    function test__ERC721AFeeHandler__EmitEvent__SetTokenFee() public {
        address owner = nftContract.owner();

        vm.expectEmit(true, true, true, true);
        emit TokenFeeSet(owner, NEW_FEE);

        vm.prank(owner);
        nftContract.setTokenFee(NEW_FEE);
    }

    function test__ERC721AFeeHandler__RevertWhen__NotOwnerSetsTokenFee() public {
        vm.prank(USER);

        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, USER));
        nftContract.setTokenFee(NEW_FEE);
    }

    /*//////////////////////////////////////////////////////////////
                               TEST MINT
    //////////////////////////////////////////////////////////////*/

    /// SUCCESS
    ////////////////////////////////////////////////////////////*/
    function test__ERC721AFeeHandler__Mint(uint256 quantity, address account) public skipFork {
        quantity = bound(quantity, 1, nftContract.getBatchLimit());
        vm.assume(account != address(0));
        vm.assume(account != nftContract.getFeeAddress());
        vm.assume(account.code.length == 0);

        fund(account);

        uint256 feeEthBalance = nftContract.getFeeAddress().balance;
        uint256 feeTokenBalance = token.balanceOf(nftContract.getFeeAddress());

        uint256 ethBalance = account.balance;
        uint256 tokenBalance = token.balanceOf(account);

        uint256 ethFee = quantity * nftContract.getEthFee();
        uint256 tokenFee = quantity * nftContract.getTokenFee();

        vm.startPrank(account);
        token.approve(address(nftContract), tokenFee);
        nftContract.mint{value: ethFee}(quantity);
        vm.stopPrank();

        assertEq(nftContract.balanceOf(account), quantity);

        assertEq(account.balance, ethBalance - ethFee);
        assertEq(token.balanceOf(account), tokenBalance - tokenFee);

        assertEq(nftContract.getFeeAddress().balance, feeEthBalance + ethFee);
        assertEq(token.balanceOf(nftContract.getFeeAddress()), feeTokenBalance + tokenFee);
    }

    /// REVERTS
    ////////////////////////////////////////////////////////////*/
    function test__ERC721AFeeHandler__RevertWhen__InsufficientEthFee(uint256 quantity) public funded(USER) skipFork {
        quantity = bound(quantity, 1, nftContract.getBatchLimit());

        address owner = nftContract.owner();
        vm.prank(owner);
        nftContract.setEthFee(0.1 ether);

        uint256 tokenFee = nftContract.getTokenFee() * quantity;
        uint256 ethFee = nftContract.getEthFee() * quantity;
        uint256 insufficientFee = ethFee - 0.01 ether;

        vm.prank(USER);
        token.approve(address(nftContract), tokenFee);

        vm.expectRevert(
            abi.encodeWithSelector(FeeHandler.FeeHandler_InsufficientEthFee.selector, insufficientFee, ethFee)
        );
        vm.prank(USER);
        nftContract.mint{value: insufficientFee}(quantity);
    }

    function test__ERC721AFeeHandler__RevertWhen__InsufficientAllowance() public funded(USER) {
        uint256 ethFee = nftContract.getEthFee();
        uint256 tokenFee = nftContract.getTokenFee();

        vm.expectRevert(
            abi.encodeWithSelector(IERC20Errors.ERC20InsufficientAllowance.selector, address(nftContract), 0, tokenFee)
        );
        vm.prank(USER);
        nftContract.mint{value: ethFee}(1);
    }

    function test__ERC721AFeeHandler__RevertWhen__MintTokenTransferFails(uint256 quantity) public skipFork {
        quantity = bound(quantity, 1, nftContract.getBatchLimit());

        fund(USER);

        uint256 ethFee = nftContract.getEthFee() * quantity;
        uint256 tokenFee = nftContract.getTokenFee() * quantity;

        address feeAddress = nftContract.getFeeAddress();

        vm.mockCall(
            address(token),
            abi.encodeWithSelector(token.transferFrom.selector, USER, feeAddress, tokenFee),
            abi.encode(false)
        );

        vm.expectRevert();
        vm.prank(USER);
        nftContract.mint{value: ethFee}(quantity);
    }

    function test__ERC721AFeeHandler__RevertWhen__MintEthTransferFails(uint256 quantity) public skipFork {
        quantity = bound(quantity, 1, nftContract.getBatchLimit());

        fund(USER);

        uint256 ethFee = nftContract.getEthFee() * quantity;
        uint256 tokenFee = nftContract.getTokenFee() * quantity;

        address feeAddress = nftContract.getFeeAddress();
        vm.prank(USER);
        token.approve(address(nftContract), tokenFee);

        vm.mockCallRevert(feeAddress, "", "");

        vm.expectRevert(FeeHandler.FeeHandler_EthTransferFailed.selector);
        vm.prank(USER);
        nftContract.mint{value: ethFee}(quantity);
    }

    function test__ERC721AFeeHandler__ChargesNoFeeIfZeroEthFee() public funded(USER) {
        uint256 tokenFee = nftContract.getTokenFee();

        uint256 ethBalance = USER.balance;

        address owner = nftContract.owner();
        vm.prank(owner);
        nftContract.setEthFee(0);
        console.log(nftContract.getEthFee());

        vm.prank(USER);
        token.approve(address(nftContract), tokenFee);

        vm.prank(USER);
        nftContract.mint(1);

        // correct nft balance
        assertEq(nftContract.balanceOf(USER), 1);

        // correct nft ownership
        assertEq(nftContract.ownerOf(1), USER);

        // correct eth fee charged
        assertEq(USER.balance, ethBalance);
    }
}
