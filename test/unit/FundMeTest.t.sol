// SPDX-License-Identifier: MIT
// 1. Pragma
pragma solidity 0.8.19;
// 2. Imports
import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    DeployFundMe deployFundMe;
    address BOB = makeAddr("bob");

    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;
    modifier funded() {
        vm.prank(BOB);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function setUp() external {
        deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(BOB, STARTING_BALANCE);
    }

    function testMinimumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public view {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testVersionIsCorrect() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundUpdatesFunderDataStructure() public {
        vm.prank(BOB);
        fundMe.fund{value: SEND_VALUE}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(BOB);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testGetFunder() public {
        vm.prank(BOB);
        fundMe.fund{value: SEND_VALUE}();
        address funder = fundMe.getFunder(0);
        assertEq(funder, BOB);
    }

    function testWithdrawWithASingleFunder() public funded {
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(startingFundMeBalance, 0.1 ether);
        assertEq(endingFundMeBalance, 0 ether);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
        assertEq(
            endingOwnerBalance - startingOwnerBalance,
            startingFundMeBalance
        );
    }

    function testCheaperWithdrawWithASingleFunder() public funded {
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.prank(fundMe.getOwner());
        fundMe.cheaperWithdraw();

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(startingFundMeBalance, 0.1 ether);
        assertEq(endingFundMeBalance, 0 ether);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
        assertEq(
            endingOwnerBalance - startingOwnerBalance,
            startingFundMeBalance
        );
    }

    function testCheaperWithdrawWithMultipleFunders() public funded {
        // arrange
        uint256 numberOfFunders = 10;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        // action

        vm.txGasPrice(GAS_PRICE);
        for (uint256 i = 1; i < numberOfFunders; i++) {
            address user = address(uint160(i));
            hoax(user, SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }
        uint256 startingFundMeBalance = address(fundMe).balance;
        vm.prank(fundMe.getOwner());
        fundMe.cheaperWithdraw();

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        // assert

        assertEq(endingFundMeBalance, 0 ether);
        assertEq(
            endingOwnerBalance - startingOwnerBalance,
            startingFundMeBalance
        );
    }

    function testWithdrawWithMultipleFunders() public funded {
        // arrange
        uint256 numberOfFunders = 10;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        // action

        vm.txGasPrice(GAS_PRICE);
        for (uint256 i = 1; i < numberOfFunders; i++) {
            address user = address(uint160(i));
            hoax(user, SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }
        uint256 startingFundMeBalance = address(fundMe).balance;
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        // assert

        assertEq(endingFundMeBalance, 0 ether);
        assertEq(
            endingOwnerBalance - startingOwnerBalance,
            startingFundMeBalance
        );
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(BOB);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testPriceFeed() public view {
        address priceFeed = address(fundMe.getPriceFeed());
        assertEq(deployFundMe.ethUSDPriceFeed(), priceFeed);
    }
}
