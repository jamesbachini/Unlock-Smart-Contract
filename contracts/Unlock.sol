// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Unlock is ERC20 {

    uint256 public tokenPrice = 69420; // price in wei for 1e18 tokens
    address public teamWallet;
    address public vc1;
    address public vc2;
    uint256 public deploymentTimestamp;
    uint256 public teamFundsWithdrawn;
    uint256 public vc1FundsWithdrawn;
    uint256 public vc2FundsWithdrawn;

    constructor(address _vc1, address _vc2) ERC20("Unlock Token", "UNLOCK") {
      deploymentTimestamp = block.timestamp;
      teamWallet = msg.sender;
      vc1 = _vc1;
      vc2 = _vc2;
    }

    function teamDue() public view returns(uint256) {
        // team get dynamic 1% of circulating supply or 1.25% if mktcap > 1000 ETH 
        uint256 circulatingSupply = totalSupply();
        uint256 divisionFactor = 100;
        uint256 mktCap = calculateMarketCap();
        if (mktCap > 1000 ether) divisionFactor = 80;
        uint256 teamMaxAllowed = circulatingSupply / 100;
        uint256 teamAvailable = teamMaxAllowed - teamFundsWithdrawn;
        return teamAvailable;
    }

    function vcDue(address vc) public view returns(uint256) {
        // VC1 has 1m tokens owed over 1 year with a 2x bonus if token price doubles 
        // VC2 has 2m tokens owed over 4 years with a 3x bonus if/when TVL goes over 100 ETH
        uint256 vcAvailable;
        if (vc == vc1) {
            uint256 vcTotal = 1000000 ether;
            uint256 timePassed = block.timestamp - deploymentTimestamp;
            uint256 maxDue = vcTotal * timePassed / 31560000;
            if (tokenPrice > 69420 * 2) maxDue = maxDue * 2;
            vcAvailable = maxDue - vc1FundsWithdrawn;
        } else if (vc == vc2) {
            uint256 vcTotal = 2000000 ether;
            uint256 timePassed = block.timestamp - deploymentTimestamp;
            uint256 maxDue = vcTotal * timePassed / 126200000;
            uint256 tvl = calculateTVL();
            if (tvl > 100 ether) maxDue = maxDue * 3;
            vcAvailable = maxDue - vc2FundsWithdrawn;
        }
        return vcAvailable;
    }

    function teamFunding(uint256 _amount) external payable {
        require(msg.sender == teamWallet, "Only team can withdraw");
        uint256 teamAvailable = teamDue();
        require(_amount <= teamAvailable, "Team too greedy");
        teamFundsWithdrawn += _amount;
        _mint(teamWallet, _amount);
    }

    function vcVesting(uint256 _amount) external payable {
        uint256 vcAvailable = vcDue(msg.sender);
        if (msg.sender == vc1) {
            vc1FundsWithdrawn += _amount;
        } else if (msg.sender == vc2) {
            vc2FundsWithdrawn += _amount;
            _mint(vc2, _amount);
        } else {
          revert("Not a VC");
        }
        require(_amount <= vcAvailable, "VC too greedy");
        _mint(vc1, _amount);
    }

    function calculateMarketCap() public view returns(uint256) {
        uint256 circulatingSupply = totalSupply();
        return circulatingSupply * tokenPrice / 1e18;
    }

    function calculateTVL() public view returns(uint256) {
        return address(this).balance;
    }

    function deposit() external payable {
        require(msg.value > 0, "Send some ETH");
        uint256 amount = msg.value * 1e18 / tokenPrice;
        tokenPrice = 69420 + (address(this).balance / 1e16); // 0.1 ETH moves the price 1 wei
        _mint(msg.sender, amount);
    }

    function withdraw(uint256 _amount) external {
        require(_amount > 0, "Send some tokens");
        require(balanceOf(msg.sender) >= _amount, "Not enough tokens");
        _burn(msg.sender, _amount);
        uint256 ethAmount = _amount * tokenPrice / 1e18;
        tokenPrice = 69420 + (address(this).balance / 1e16);
        payable(msg.sender).transfer(ethAmount);
    }
}