
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

|                         | Zora editions | Showtime editions | % change |
| ----------------------- | ------------- | ----------------- | -------- |
| testMintByContract()    | 57883         | 50702             | \-12.41% |
| testMintByOwner()       | 48457         | 49869             | 2.91%    |
| testMintOpenEdition()   | 67489         | 64612             | \-4.26%  |

### Batch Mint

|                         | Zora editions | Showtime editions | % change |
| ----------------------- | ------------- | ----------------- | -------- |
| testMint10ByContract()  | 525498        | 515257            | \-1.95%  |
| testMint10ByOwner()     | 512988        | 511354            | \-0.32%  |
| testMint10OpenEdition() | 515336        | 509392            | \-1.15%  |

### View Functions

|                         | Zora editions | Showtime editions | % change |
| ----------------------- | ------------- | ----------------- | -------- |
| testContractURI()       | n/a           | 42595             |          |
| testTokenURI()          | 55674         | 42986             | \-22.79% |

### Other

|                         | Zora editions | Showtime editions | % change |
| ----------------------- | ------------- | ----------------- | -------- |
| testTransferFrom()      | 43090         | 40465             | \-6.09%  |
