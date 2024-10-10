# 📈 OrderBook Solidity Smart Contract

## Table of Contents
- [Introduction](#introduction)
- [Features](#features)
- [Smart Contract Details](#smart-contract-details)
- [Getting Started](#getting-started)
- [Deploying the Smart Contract](#deploying-the-smart-contract)
- [Running Tests](#running-tests)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

## Introduction
`OrderBook` est un smart contract décentralisé écrit en Solidity qui permet de gérer un carnet d'ordres pour l'achat et la vente de tokens ERC20. Il implémente un système de correspondance d'ordres qui facilite les échanges de tokens entre les utilisateurs de manière décentralisée, transparente et sécurisée.

## Features
- 📊 **Order Placement**: Permet de placer des ordres d'achat et de vente de tokens ERC20.
- ⚖️ **Order Matching**: Les ordres sont automatiquement associés et exécutés si les conditions de prix et de quantité sont remplies.
- 🔍 **Order Tracking**: Les utilisateurs peuvent visualiser les ordres existants et l'état des ordres ouverts.
- 🔐 **Secure Trading**: Utilise les normes ERC20 et les vérifications Solidity pour garantir la sécurité des échanges.

## Smart Contract Details
Le smart contract `OrderBook` prend en charge deux tokens ERC20 (définis lors du déploiement). Les utilisateurs peuvent placer des ordres d'achat ou de vente en spécifiant la quantité, le prix, et le type d'ordre (achat ou vente). Si un ordre correspondant est trouvé, le trade est automatiquement exécuté.

### Technologies utilisées
- **Solidity**: Version `^0.8.0`
- **OpenZeppelin**: Utilisé pour l'implémentation des interfaces et standards ERC20.
- **Foundry**: Pour tester et déployer le smart contract.

## Getting Started

### Prérequis

- **Foundry** (outil de développement et de testing Solidity)
- **OpenZeppelin** (pour les interfaces ERC20)

### Installation

Installation des dépendances :

```bash
forge install
```

### Deploying the Smart Contract

Pour déployer le smart contract OrderBook, tu peux utiliser Foundry. Le script de déploiement prend en paramètre les adresses des tokens ERC20 :

```bash
forge script script/DeployOrderbook.s.sol --rpc-url {YOUR_RPC_URL} --private-key {YOUR_PRIVATE_KEY} --broadcast
```

### Running Tests

Le projet utilise Foundry pour exécuter les tests. Voici comment lancer tous les tests :

```bash
forge test
forge coverage
```

Les tests couvrent plusieurs cas :

Placer des ordres d'achat et de vente.
Vérifier la correspondance des ordres.
Tester les cas de non-matching lorsque les prix diffèrent.
Gérer les ordres partiellement remplis.

### Usage

Placer un ordre
Les utilisateurs peuvent interagir avec le smart contract pour placer un ordre d'achat ou de vente :

_amount : La quantité de tokens.
_price : Le prix par token.
_orderType : Type de l'ordre (Buy ou Sell).

```bash
orderBook.placeOrder(100, 50, OrderBook.OrderType.Buy);
```

Visualiser les ordres
Les utilisateurs peuvent visualiser tous les ordres existants :

```bash
orderBook.getOrders();
```

### Contributing

Les contributions sont les bienvenues ! Si vous souhaitez améliorer le projet, merci de suivre les étapes suivantes :

Fork le projet.
Crée une nouvelle branche (git checkout -b feature/amazing-feature).
Fais un commit de tes modifications (git commit -m 'Add amazing feature').
Pousse les modifications (git push origin feature/amazing-feature).
Ouvre une Pull Request.

### License

Ce projet est sous licence MIT. Consultez le fichier LICENSE pour plus d’informations.