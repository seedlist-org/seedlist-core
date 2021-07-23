## Development

### Prerequisites

- nodejs 14.15.1
- hardhat 2.3.0

### Install Dependencies

```bash
npm install
```

### Compile

```bash
npx hardhat compile
```

### Running the tests

```bash
npx hardhat test
```

### Deploy

```bash
npx hardhat run scripts/deploy.js --network rinkeby/ropsten/...
```
After deployed finish, treasury contract address will be displayed, please remember it which
will be used in seedlist-core deployed.

## Contributions

Fork, code and make pull request against the `main` branch.

## License

[MIT](LICENSE).
