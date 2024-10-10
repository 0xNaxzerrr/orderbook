// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract OrderBook {
    enum OrderType { Buy, Sell }
    
    struct Order {
        address trader;
        uint256 amount;
        uint256 price;
        OrderType orderType;
        bool isFilled;
    }
    
    IERC20 public tokenA;
    IERC20 public tokenB;
    Order[] public orders;
    uint256 public orderCount;

    event OrderPlaced(uint256 orderId, address indexed trader, uint256 amount, uint256 price, OrderType orderType);
    event OrderExecuted(uint256 buyOrderId, uint256 sellOrderId, uint256 amount);

    constructor(address _tokenA, address _tokenB) {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
    }

    function placeOrder(uint256 _amount, uint256 _price, OrderType _orderType) payable external {
        require(_amount > 0, "Amount must be greater than 0");
        require(_price > 0, "Price must be greater than 0");

        // Transfert du montant du token vendu vers le smart contract si c'est un ordre de vente
        if (_orderType == OrderType.Sell) {
            require(tokenA.transferFrom(msg.sender, address(this), _amount), "Transfer of tokenA failed");
        }

        Order memory newOrder = Order({
            trader: msg.sender,
            amount: _amount,
            price: _price,
            orderType: _orderType,
            isFilled: false
        });

        // Chercher un ordre correspondant dans l'orderbook
        for (uint256 i = 0; i < orders.length; i++) {
            Order storage existingOrder = orders[i];

            // Vérifier que l'ordre n'est pas rempli et que les types correspondent
            if (!existingOrder.isFilled && existingOrder.orderType != _orderType) {
                if ((_orderType == OrderType.Buy && _price >= existingOrder.price) ||
                    (_orderType == OrderType.Sell && _price <= existingOrder.price)) {
                    
                    // Calculer la quantité à échanger
                    uint256 tradeAmount = (newOrder.amount < existingOrder.amount) ? newOrder.amount : existingOrder.amount;

                    if (_orderType == OrderType.Buy) {
                        // Le smart contract reçoit TokenB du buyer (msg.sender) et envoie TokenA au buyer
                        uint256 paymentAmount = tradeAmount * existingOrder.price;
                        require(tokenB.transferFrom(msg.sender, existingOrder.trader, paymentAmount), "Payment transfer failed");
                        require(tokenA.transfer(msg.sender, tradeAmount), "TokenA transfer to buyer failed");
                    } else {
                        // Le smart contract envoie TokenB au vendeur et reçoit TokenA
                        uint256 paymentAmount = tradeAmount * newOrder.price;
                        require(tokenB.transfer(newOrder.trader, paymentAmount), "Payment transfer to seller failed");
                        require(tokenA.transfer(existingOrder.trader, tradeAmount), "TokenA transfer to buyer failed");
                    }

                    // Mettre à jour les quantités et l'état des ordres
                    newOrder.amount -= tradeAmount;
                    existingOrder.amount -= tradeAmount;

                    emit OrderExecuted(orderCount, i, tradeAmount);

                    // Si l'un des ordres est complètement rempli, le marquer comme rempli
                    if (newOrder.amount == 0) {
                        newOrder.isFilled = true;
                        break; // Sortir de la boucle car l'ordre est rempli
                    }
                    if (existingOrder.amount == 0) {
                        existingOrder.isFilled = true;
                    }
                }
            }
        }

        // Si l'ordre n'est pas complètement rempli, l'ajouter à l'orderbook
        if (!newOrder.isFilled) {
            orders.push(newOrder);
            emit OrderPlaced(orderCount, msg.sender, _amount, _price, _orderType);
            orderCount++;
        }
    }

    function getOrders() external view returns (Order[] memory) {
        return orders;
    }
}
