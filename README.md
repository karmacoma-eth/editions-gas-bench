
```sh
# fetch the dependencies from the respective projects
(cd lib/showtime-nft-editions && forge build)
(cd lib/zora-nft-editions && npm i)

# update the gas snapshot
forge snapshot

# parse it to csv
./bin/parse-gas-snapshot.py
```

## Results

### Creating a new edition

|                         | Zora editions | Showtime editions | % change |
| ----------------------- | ------------- | ----------------- | -------- |
| testCreateNewEdition()  | 341563        | 225259            | \-34.05% |

### Single Mint

|                         | ZoraEditions | ShowtimeEditions | % change |
| ----------------------- | ------------ | ---------------- | -------- |
| testMintByContract()    | 77094        | 69909            | \-9.32%  |
| testMintByOwner()       | 67659        | 69082            | 2.10%    |
| testMintOpenEdition()   | 69596        | 66725            | \-4.13%  |

(this is the cost to mint to an address with a 0 balance)

### Batch Mint

|                         | Zora editions | Showtime editions | % change |
| ----------------------- | ------------- | ----------------- | -------- |
| testMint10ByContract()  | 525498        | 515257            | \-1.95%  |
| testMint10ByOwner()     | 512988        | 511354            | \-0.32%  |
| testMint10OpenEdition() | 515336        | 509392            | \-1.15%  |

### Paid Mint

|                           | Zora Editions | Showtime Editions | % change |
| ------------------------- | ------------- | ----------------- | -------- |
| testPaidMintByContract()  | 98247         | 83365             | \-15.15% |
| testPaidMintOpenEdition() | 78051         | 73447             | \-5.90%  |

Note: Zora editions only send paid mints to `msg.sender`, so doing a paid mint via a contract means that we need to also transfer the NFT to the actual buyer.

### View Functions

|                         | Zora editions | Showtime editions | % change |
| ----------------------- | ------------- | ----------------- | -------- |
| testContractURI()       | n/a           | 42595             |          |
| testTokenURI()          | 55674         | 42986             | \-22.79% |

### Other

|                         | Zora editions | Showtime editions | % change |
| ----------------------- | ------------- | ----------------- | -------- |
| testTransferFrom()      | 43090         | 40465             | \-6.09%  |
