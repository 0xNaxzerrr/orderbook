// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Orderbook.sol";
import "../src/MyTokenA.sol";
import "../src/MyTokenB.sol";

contract OrderBookTest is Test {
    OrderBook orderBook;
    MyTokenA tokenA;
    MyTokenB tokenB;
    address user1 = address(0x1);
    address user2 = address(0x2);

    function setUp() public {
        // Déployer les tokens avec un supply initial de 1000 tokens chacun
        tokenA = new MyTokenA(1000);
        tokenB = new MyTokenB(1000);

        // Déployer le contrat OrderBook avec les adresses des tokens
        orderBook = new OrderBook(address(tokenA), address(tokenB));

        // Distribuer des tokens aux utilisateurs
        tokenA.transfer(user1, 100);
        tokenB.transfer(user2, 100);

        // Autoriser le contrat OrderBook à dépenser les tokens de user1 et user2
        vm.startPrank(user1);
        tokenA.approve(address(orderBook), 100);
        vm.stopPrank();

        vm.startPrank(user2);
        tokenB.approve(address(orderBook), 100);
        vm.stopPrank();
    }

    function testPlaceBuyOrder() public {
        // Simuler que user2 place un ordre d'achat de 10 tokenA au prix de 5 tokenB chacun
        vm.startPrank(user2);
        orderBook.placeOrder{value: 0}(10, 5, OrderBook.OrderType.Buy);

        // Vérifier que l'ordre a bien été placé
        (address trader, uint256 amount, uint256 price, OrderBook.OrderType orderType, bool isFilled) = orderBook.orders(0);
        assertEq(trader, user2);
        assertEq(amount, 10);
        assertEq(price, 5);
        assertEq(uint256(orderType), uint256(OrderBook.OrderType.Buy));
        assertFalse(isFilled);
        vm.stopPrank();
    }

    function testPlaceSellOrder() public {
        // Simuler que user1 place un ordre de vente de 10 tokenA au prix de 5 tokenB chacun
        vm.startPrank(user1);
        orderBook.placeOrder{value: 0}(10, 5, OrderBook.OrderType.Sell);

        // Vérifier que l'ordre a bien été placé
        (address trader, uint256 amount, uint256 price, OrderBook.OrderType orderType, bool isFilled) = orderBook.orders(0);
        assertEq(trader, user1);
        assertEq(amount, 10);
        assertEq(price, 5);
        assertEq(uint256(orderType), uint256(OrderBook.OrderType.Sell));
        assertFalse(isFilled);
        vm.stopPrank();
    }

    function testMatchOrders() public {
        // Simuler que user1 place un ordre de vente de 10 tokenA au prix de 5 tokenB chacun
        vm.startPrank(user1);
        orderBook.placeOrder{value: 0}(10, 5, OrderBook.OrderType.Sell);
        vm.stopPrank();

        // Simuler que user2 place un ordre d'achat de 10 tokenA au prix de 5 tokenB chacun
        vm.startPrank(user2);
        orderBook.placeOrder{value: 0}(10, 5, OrderBook.OrderType.Buy);
        vm.stopPrank();

        // Vérifier que l'ordre a été exécuté et que les soldes ont changé
        assertEq(tokenA.balanceOf(user2), 10); // user2 reçoit 10 tokenA
        assertEq(tokenB.balanceOf(user1), 50); // user1 reçoit 50 tokenB (10 * 5)
    }

    function testPartialMatch() public {
        // Simuler que user1 place un ordre de vente de 20 tokenA au prix de 5 tokenB chacun
        vm.startPrank(user1);
        orderBook.placeOrder{value: 0}(20, 5, OrderBook.OrderType.Sell);
        vm.stopPrank();

        // Simuler que user2 place un ordre d'achat de 10 tokenA au prix de 5 tokenB chacun
        vm.startPrank(user2);
        orderBook.placeOrder{value: 0}(10, 5, OrderBook.OrderType.Buy);
        vm.stopPrank();

        // Vérifier que l'ordre de vente est partiellement exécuté
        (, uint256 remainingAmount, , , bool isFilled) = orderBook.orders(0);
        assertEq(remainingAmount, 10); // 10 tokenA restants
        assertFalse(isFilled); // L'ordre n'est pas encore complètement rempli

        // Vérifier que les soldes ont changé
        assertEq(tokenA.balanceOf(user2), 10); // user2 reçoit 10 tokenA
        assertEq(tokenB.balanceOf(user1), 50); // user1 reçoit 50 tokenB
    }

    function testOrderNotMatchingPrice() public {
        // Simuler que user1 place un ordre de vente de 10 tokenA au prix de 6 tokenB chacun
        vm.startPrank(user1);
        orderBook.placeOrder{value: 0}(10, 6, OrderBook.OrderType.Sell);
        vm.stopPrank();

        // Simuler que user2 place un ordre d'achat de 10 tokenA au prix de 5 tokenB chacun
        vm.startPrank(user2);
        orderBook.placeOrder{value: 0}(10, 5, OrderBook.OrderType.Buy);
        vm.stopPrank();

        // Vérifier que les ordres ne se correspondent pas
        (, uint256 amountSell, , , bool isFilledSell) = orderBook.orders(0);
        (, uint256 amountBuy, , , bool isFilledBuy) = orderBook.orders(1);
        assertEq(amountSell, 10);
        assertEq(amountBuy, 10);
        assertFalse(isFilledSell);
        assertFalse(isFilledBuy);
    }
}
