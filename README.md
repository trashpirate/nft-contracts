# FOUNDRY STARTER

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg?style=for-the-badge)
![Forge](https://img.shields.io/badge/forge-v0.2.0-blue.svg?style=for-the-badge)
![Solc](https://img.shields.io/badge/solc-v0.8.20-blue.svg?style=for-the-badge)
[![GitHub License](https://img.shields.io/github/license/trashpirate/foundry-starter?style=for-the-badge)](https://github.com/trashpirate/foundry-starter/blob/master/LICENSE)

[![Website: nadinaoates.com](https://img.shields.io/badge/Portfolio-00e0a7?style=for-the-badge&logo=Website)](https://nadinaoates.com)
[![LinkedIn: nadinaoates](https://img.shields.io/badge/LinkedIn-0a66c2?style=for-the-badge&logo=LinkedIn&logoColor=f5f5f5)](https://linkedin.com/in/nadinaoates)
[![Twitter: 0xTrashPirate](https://img.shields.io/badge/@0xTrashPirate-black?style=for-the-badge&logo=X)](https://twitter.com/0xTrashPirate)


## About

_**DISCLAIMER: This code is provided as-is and has not been audited for security or functionality. Use at your own risk.**_

Collection of modular NFT contracts and extensions based on the ERC721 & ERC721A standards. The modules include:

**Base contract**  
- ERC721ACore: Basic NFT contract with minting and transfer functions including a max wallet size (default: 10), batch limit (default: 10), royalties, and withdraw functions for ETH and ERC20 tokens.

**Utilitites**  
- Pausable: Pausable NFT contract extension with pause and unpause functions.

**Extensions**  
- FeeHandler: Extension to handle fees for minting in native coins and ERC20 tokens.
- PseudoRandomized: Extension to handle pseudo-randomized minting
- Whitelist: Extension to handle whitelisted minting

## Installation

### Install dependencies
```bash
$ make install
```

## Usage
Before running any commands, create a .env file and add the following environment variables:

```bash
# NFT configurations
COLLECTION_NAME=<"collection name">
SYMBOL=<"nft sybmol">
BASE_URI="base uri" # ipfs://<cid>
CONTRACT_URI="contract uri" # ipfs://<cid>
MAX_SUPPLY=<"maximum number of nfts">
ETH_FEE=<"minting fee in native token"> # in wei
TOKEN_FEE=<"minting in erc20 token"> # in wei

OWNER_ADDRESS=<"owner address">
FEE_ADDRESS=<"address for minting fees">
TOKEN_ADDRESS=<"token address">

MERKLE_ROOT=<"root hash">


# anvil wallets
ANVIL_DEFAULT_ACCOUNT=<"default account address">
ANVIL_DEFAULT_KEY=<"default account private key">

# accounts to deploy/interact with contracts
ACCOUNT_NAME=<"account name">
ACCOUNT_ADDRESS=<"account address">

# network configs
RPC_LOCALHOST="http://127.0.0.1:8545"

# ethereum nework
RPC_TEST=<"rpc url">
RPC_MAIN=<"rpc url">
ETHERSCAN_KEY=<"api key">


```

Update chain ids in the `HelperConfig.s.sol` file for the chain you want to configure:

- Ethereum: 1 | Sepolia: 11155111 
- Base: 8453 | Base sepolia: 84532
- Bsc: 56 | Bsc Testnet: 97

### Run tests
```bash
$ forge test
```

### Generate Merkle tree and proofs

1. Navigate to the `utils/merkle-tree-generator` directory
2. Place the csv file containing the list of whitelist addresses in the `data` directory
3. Run the following command to generate the merkle tree for whitelist:
    ```bash
    $ node generateTree.js <csv_filename>
    ```
4. To generate the merkle proof for a specific address run:
    ```bash
    $ node generateProof.js <address>
    ```
For deployment, paste the merkle root into the `.env` file.

## Deployments

### Testnet
### Mainnet

## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Author

👤 **Nadina Oates**

* Website: [nadinaoates.com](https://nadinaoates.com)
* Twitter: [@0xTrashPirate](https://twitter.com/0xTrashPirate)
* Github: [@trashpirate](https://github.com/trashpirate)
* LinkedIn: [@nadinaoates](https://linkedin.com/in/nadinaoates)


## 📝 License

Copyright © 2024 [Nadina Oates](https://github.com/trashpirate).

