// SPDX-License-Identifier: MIT
// Dev Inu Deflationary token on DevETH Network
pragma solidity ^0.8.7;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f1e92dd184a599f39ce9cc4ec8a5e4a94416f3a2/contracts/utils/math/SafeMath.sol";

contract DevInu is ERC20 {
    using SafeMath for uint256;
    
    uint DEV_INU_TAX = 1; // 1% tax
    uint DEV_INU_BURN = 4; // 4% burn
    uint DEV_COUNT = 0;
    address public owner;
    mapping (address => bool) excludedFromTax;
    mapping (address => bool) signedDevCount;
    
    
    constructor(uint256 initialSupply) ERC20("Dev Inu", "DINU") {
        _mint(msg.sender, initialSupply * (10**18));
        owner = msg.sender;
        
        excludedFromTax[msg.sender] = true;
    }
    
    function transfer(address recipient, uint256 amount) public override returns(bool){
        if(excludedFromTax[msg.sender]) {
            _transfer(_msgSender(), recipient, amount);
        } else {
            uint burnAmount = amount.mul(DEV_INU_BURN) / 100;
            uint adminAmount = amount.mul(DEV_INU_TAX) / 100;
            _burn(_msgSender(), burnAmount);
            _transfer(_msgSender(), owner, adminAmount);
            _transfer(_msgSender(), recipient, amount.sub(burnAmount).sub(adminAmount));
        }
        
        return true;
    }

    function iAmDev() public returns(bool) {
        if(!signedDevCount[msg.sender]) {
            if(this.balanceOf(msg.sender) > 1000 * (10**18)) {
                signedDevCount[msg.sender] = true;
                DEV_COUNT = DEV_COUNT + 1; // cheers
                return true;
            }
        }
        return false;
    }

    function getDevs() public view returns(uint) {
        return DEV_COUNT;
    }
}