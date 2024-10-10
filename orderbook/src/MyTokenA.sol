// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyTokenA is ERC20 {
    constructor(uint256 initialSupply) ERC20("TokenA", "TA") {
        // Créer un nombre initial de tokens pour l'adresse qui déploie le contrat
        _mint(msg.sender, initialSupply * (10 ** decimals()));
    }

    // Optionnel: Cette fonction retourne le nombre de décimales utilisées
    function decimals() public view virtual override returns (uint8) {
        return 18; // 18 décimales, comme c'est courant dans les ERC20
    }
}