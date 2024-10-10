// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/OrderBook.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20Mock is ERC20 {
    constructor(string memory name, string memory symbol, uint256 initialSupply) ERC20(name, symbol) {
        _mint(msg.sender, initialSupply);
    }
}

contract OrderBookTest is Test {
    OrderBook orderBook;
    ERC20Mock tokenA;
    address addr1 = address(0x123);
    address addr2 = address(0x456);

    function setUp() public {
        tokenA = new ERC20Mock("TokenA", "TKA", 1000 ether);
        orderBook = new OrderBook();
        vm.prank(addr1);
        tokenA.transfer(addr1, 100 ether);
        vm.prank(addr2);
        tokenA.transfer(addr2, 100 ether);
    }

    function testPlaceBuyOrder() public {
        vm.prank(addr1);
        orderBook.placeOrder(tokenA, 10 ether, 1 ether, OrderBook.OrderType.Buy);
        (address trader, , uint256 amount, uint256 price, ) = orderBook.orders(0);
        assertEq(trader, addr1);
        assertEq(amount, 10 ether);
        assertEq(price, 1 ether);
    }

    function testPlaceSellOrder() public {
        vm.prank(addr1);
        tokenA.approve(address(orderBook), 10 ether);
        vm.prank(addr1);
        orderBook.placeOrder(tokenA, 10 ether, 1 ether, OrderBook.OrderType.Sell);
        (address trader, , uint256 amount, uint256 price, ) = orderBook.orders(0);
        assertEq(trader, addr1);
        assertEq(amount, 10 ether);
        assertEq(price, 1 ether);
    }

    function testMatchOrders() public {
        vm.prank(addr1);
        orderBook.placeOrder(tokenA, 10 ether, 1 ether, OrderBook.OrderType.Buy);
        vm.prank(addr2);
        tokenA.approve(address(orderBook), 10 ether);
        vm.prank(addr2);
        orderBook.placeOrder(tokenA, 10 ether, 1 ether, OrderBook.OrderType.Sell);

        vm.prank(addr2);
        orderBook.matchOrders(0, 1);

        (address traderBuy, , uint256 amountBuy, , ) = orderBook.orders(0);
        (address traderSell, , uint256 amountSell, , ) = orderBook.orders(1);
        assertEq(amountBuy, 0);
        assertEq(amountSell, 0);
    }
}
