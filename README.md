# Cryptocurrency Portfolio Monitoring

A cross-platform app (mobile, desktop, and web) built with Flutter for tracking cryptocurrency investments. I developed it as my final thesis in Computer Science at the Federal University of Viçosa (UFV), and it received the maximum grade.

The project fills a gap in free tools for crypto investors. It combines portfolio tracking, live market data, price alerts, and on-chain transaction lookup in one app.

## Features

- **Multiple portfolios:** create, switch between, and delete portfolios. Each one lists its coins sorted by current position value.
- **Live market data:** current prices and 24h price variation for the top 100 cryptocurrencies by market cap, from the [CoinGecko API](https://www.coingecko.com/en/api).
- **Position tracking:** holdings with quantity, average purchase price, and current value. Adding more of a coin you already hold recalculates the average price.
- **CSV import:** import a whole portfolio from a `.csv` file (see the format below).
- **Price alerts:** set a target price for any coin. Alerts are marked as resolved once the market price rises above the target.
- **On-chain data:** look up the transaction history of any wallet address (Ethereum mainnet by default) through the [Blockdaemon Universal API](https://docs.blockdaemon.com/reference/universal-api-overview), showing block, date, status, and confirmations for each transaction, so you can trace how funds move through an account.
- **Offline-first storage:** portfolios and alerts are stored locally with SQLite.

## Tech stack

| Layer | Technology |
|---|---|
| App | Flutter, Dart |
| Local storage | SQLite (`sqflite`) |
| Market data | CoinGecko REST API |
| Blockchain data | Blockdaemon Universal API (Ethereum) |
| Other | `http`, `csv`, `file_picker`, `path_provider`, `logger` |

## Project structure

```
application/lib/
├── constants/   # Colors and text styles
├── helpers/     # Data access: SQLite, CoinGecko, Blockdaemon, alerts
├── models/      # Cryptocurrency, Alert, Transaction
├── utils/       # CSV import
└── view/        # Screens, shared components, splash page
```

## Running locally

Requirements: [Flutter](https://docs.flutter.dev/get-started/install) (Dart SDK 3.1.3 or later).

```bash
cd application
flutter pub get
flutter run
```

The on-chain transaction lookup needs a Blockdaemon API key (the free tier works). Pass it at build time, so it never lives in the source code:

```bash
flutter run --dart-define=BLOCKDAEMON_API_KEY=your_key
```

The rest of the app works without a key.

## CSV import format

One coin per line, with fields separated by semicolons: `symbol;quantity;average purchase price`. The file name becomes the portfolio name.

```
btc;0.5;42000
eth;3;2500
sol;20;95
```

## License

[MIT](LICENSE)
