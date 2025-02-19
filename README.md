# CryptoKnights NFT Platform

CryptoKnights is a medieval-themed NFT platform built on the Stacks blockchain using Clarity smart contracts. The platform enables users to mint, trade, and manage unique knight NFTs through a decentralized marketplace called the Tavern.

## Table of Contents
- [Features](#features)
- [Technical Architecture](#technical-architecture)
- [Smart Contract Functions](#smart-contract-functions)
- [Installation](#installation)
- [Usage](#usage)
- [Testing](#testing)
- [Security Considerations](#security-considerations)
- [Contributing](#contributing)
- [License](#license)

## Features

### Core NFT Functionality
- Mint unique knight NFTs with customizable metadata
- Transfer knights between addresses
- List knights for sale in the Tavern marketplace
- Purchase knights using STX tokens
- Batch operations for efficient minting and transfers

### Knight Management
- Each knight has unique attributes stored in metadata
- Tradeability can be enabled/disabled per knight
- Knight ownership tracked on-chain
- Metadata URI system for storing knight characteristics

### Player Progress System
- Track honor points and rank for each player
- Maximum rank cap of 100
- Honor points system with 10,000 point maximum
- On-chain player statistics tracking

### Tavern Marketplace
- List knights for sale at custom prices
- Purchase listed knights with STX
- Remove listings from the marketplace
- Automatic transfer of funds and NFTs upon purchase

## Technical Architecture

### Data Structures

```clarity
;; Knight Data
{ 
    knight-id: uint,
    owner: principal,
    metadata-uri: string-utf8,
    tradeable: bool 
}

;; Tavern Listing
{
    knight-id: uint,
    seller: principal,
    price: uint,
    listed-at: uint
}

;; Player Stats
{
    honor-points: uint,
    rank: uint
}
```

### Constants
- `max-knight-rank`: 100
- `max-honor-points`: 10,000
- `max-metadata-length`: 256
- `max-batch-size`: 10

## Smart Contract Functions

### Minting Operations
- `mint-single-knight`: Mint a new knight NFT
- `batch-mint-knights`: Mint multiple knights in one transaction

### Transfer Operations
- `transfer-single-knight`: Transfer a knight to another address
- `batch-transfer-knights`: Transfer multiple knights in one transaction

### Tavern Operations
- `list-knight-in-tavern`: List a knight for sale
- `purchase-knight`: Buy a listed knight
- `remove-from-tavern`: Remove a knight listing

### Player Management
- `update-knight-stats`: Update player's honor points and rank
- `get-knight-stats`: Retrieve player statistics

### Read-Only Functions
- `get-knight-details`: Get knight metadata and ownership info
- `get-tavern-listing`: Get marketplace listing details
- `get-total-knights`: Get total number of minted knights

## Installation

1. Install the Clarity development environment:
```bash
npm install -g @stacks/cli
```

2. Clone the repository:
```bash
git clone https://github.com/ddivinee/medieval-themed-NFT-platform
cd crypto-knights
```

3. Install dependencies:
```bash
npm install
```

## Usage

### Deploying the Contract

1. Configure your Stacks wallet and network settings
2. Deploy using the Stacks CLI:
```bash
stx deploy crypto-knights.clar
```

### Interacting with the Contract

#### Minting Knights
```clarity
;; Mint a single knight
(contract-call? .crypto-knights mint-knight 'metadata-uri' true)

;; Batch mint knights
(contract-call? .crypto-knights batch-mint-knights (list 'uri1' 'uri2') (list true true))
```

#### Trading Knights
```clarity
;; List knight for sale
(contract-call? .crypto-knights list-knight-in-tavern u1 u1000)

;; Purchase knight
(contract-call? .crypto-knights purchase-knight u1)
```

## Testing

Run the test suite:
```bash
npm test
```

Key test scenarios:
- Minting functionality
- Transfer operations
- Marketplace mechanics
- Player stats updates
- Error conditions
- Access control

## Security Considerations

1. Access Control
   - Contract owner privileges
   - Transfer authorization checks
   - Listing ownership verification

2. Input Validation
   - Price validation
   - Metadata URI length checks
   - Batch operation size limits

3. Asset Safety
   - Transfer validation
   - Ownership verification
   - Marketplace listing checks

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

---

For more information or support:
- GitHub Issues: [Project Issues](https://github.com/ddivinee/medieval-themed-NFT-platform/issues)
- Documentation: [Project Wiki](https://github.com/ddivinee/medieval-themed-NFT-platform/wiki)