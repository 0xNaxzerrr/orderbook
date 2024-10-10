// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract OrderBook {
    enum OrderType { Buy, Sell }
    
    struct Order {
        address trader;
        IERC20 token;
        uint256 amount;
        uint256 price;
        OrderType orderType;
    }
    
    Order[] public orders;
    uint256 public orderCount;

    event OrderPlaced(uint256 orderId, address indexed trader, address token, uint256 amount, uint256 price, OrderType orderType);
    event OrderExecuted(uint256 buyOrderId, uint256 sellOrderId, uint256 amount);

    function placeOrder(IERC20 _token, uint256 _amount, uint256 _price, OrderType _orderType) external {
        require(_amount > 0, "Amount must be greater than 0");
        require(_price > 0, "Price must be greater than 0");
        
        if (_orderType == OrderType.Sell) {
            require(_token.transferFrom(msg.sender, address(this), _amount), "Transfer failed");
        }

        orders.push(Order({
            trader: msg.sender,
            token: _token,
            amount: _amount,
            price: _price,
            orderType: _orderType
        }));

        emit OrderPlaced(orderCount, msg.sender, address(_token), _amount, _price, _orderType);
        orderCount++;
    }

    function matchOrders(uint256 buyOrderId, uint256 sellOrderId) external {
        Order storage buyOrder = orders[buyOrderId];
        Order storage sellOrder = orders[sellOrderId];

        require(buyOrder.orderType == OrderType.Buy, "First order must be a buy order");
        require(sellOrder.orderType == OrderType.Sell, "Second order must be a sell order");
        require(buyOrder.token == sellOrder.token, "Tokens must match");
        require(buyOrder.price >= sellOrder.price, "Buy price must be greater than or equal to sell price");
        
        uint256 tradeAmount = (buyOrder.amount < sellOrder.amount) ? buyOrder.amount : sellOrder.amount;

        // Transfer tokens
        require(sellOrder.token.transfer(buyOrder.trader, tradeAmount), "Transfer to buyer failed");
        payable(sellOrder.trader).transfer(tradeAmount * sellOrder.price);

        // Update order amounts
        buyOrder.amount -= tradeAmount;
        sellOrder.amount -= tradeAmount;

        emit OrderExecuted(buyOrderId, sellOrderId, tradeAmount);
    }

    function getOrders() external view returns (Order[] memory) {
        return orders;
    }
}
