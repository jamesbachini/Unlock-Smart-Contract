# Unlock Smart Contract

Inspired by @UnlocksCalendar tweet:

> "Very difficult to find the right balance between projects with no VCs involved (might lack funding in bear mrkt) and projects with massive VCs investments (might dump on you). Would be cool to have smart contracts with team / VCs compensations based on project milestones"

https://twitter.com/UnlocksCalendar/status/1562179750784794624

The contract is here: https://github.com/jamesbachini/Unlock-Smart-Contract/blob/main/contracts/Unlock.sol

The main idea I wanted to incorporate was to align incentives with actionable milestones for the team and VC's. Unlock.sol is a simple vault with an ERC20 token and some logic to control team allocations and VC vesting schedules with milestone bonuses.

## Team allocation

Team get dynamic 1% of circulating supply or 1.25% if mktcap > 1000 ETH. So at any point the team can call this function which will withdraw up to 1% of the circulating supply.

For example if the circulating supply is 1000 tokens and the team has already taken 5 previously they are now due another 5. As the funds come in to the contract the circulating supply increases meaning the team has more funds to work with.

## VC Funding

There are two VC's with different terms:-

- VC1 has 1m tokens owed linearly over 1 year with a 2x bonus if token price doubles 
- VC2 has 2m tokens owed linearly over 4 years with a 3x bonus if/when TVL goes over 100 ETH

## Testing

Basic unit tests are setup, run with the following:
```shell
npm install
npx hardhat test
```

Code is experimental, not professionally tested and for demonstration purposes only. Not suitable for financial transactions, don't deploy on mainnet.

For more information, memes and Solidity tutorials:

- Blog: https://jamesbachini.com
- YouTube: https://www.youtube.com/c/JamesBachini
- Twitter: https://twitter.com/james_bachini
