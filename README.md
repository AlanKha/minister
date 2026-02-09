# Minister

Personal finance tracker powered by Stripe Financial Connections. Pulls bank transactions, categorizes spending, and displays weekly breakdowns.

## Architecture

- **Root** — Flutter app (iOS, macOS, web) with Riverpod state management and fl_chart visualizations
- **`server/`** — Dart shelf HTTP server (port 3000) handling Stripe API calls, transaction processing, and static file serving
- **`server/data/`** — JSON storage for transactions, category summaries, and weekly breakdowns

## Setup

### Server

```bash
cd server
dart pub get
```

Set environment variables for Stripe:

```bash
export stripe_env=test
export stripe_test_secret_key=sk_test_...
export stripe_test_publishable_key=pk_test_...
```

Run the server:

```bash
dart run bin/server.dart
```

### App

```bash
flutter pub get
flutter run -d chrome    # web
flutter run -d macos     # macOS (requires Xcode)
```

## How it works

1. **Link accounts** — The server hosts a Stripe Financial Connections flow. Connect your bank accounts through the UI; linked accounts are stored in `server/data/linked_account.json`.

2. **Fetch transactions** — The server pulls transactions from Stripe for each linked account and appends new ones to `server/data/transactions.json`.

3. **Categorize & summarize** — Transactions are matched against ~180 regex rules, cleaned, and broken down into:
   - `server/data/transactions_clean.json` — all cleaned transactions
   - `server/data/category_summary.json` — totals per category
   - `server/data/weekly/<date>/` — per-week breakdowns

4. **Visualize** — The Flutter app displays spending by category, weekly trends, and transaction details.

## File structure

```bash
lib/                           # Flutter app source
server/
  bin/server.dart              # Entry point (Cascade: API routes + static files)
  lib/category_rules.dart      # ~180 regex-to-category rules
  lib/store/json_store.dart    # JSON file read/write operations
  lib/routes/                  # shelf_router API routes
  data/
    linked_account.json        # Linked accounts (gitignored)
    transactions.json          # Raw transactions (gitignored)
    transactions_clean.json    # Cleaned transactions (gitignored)
    category_summary.json      # Category totals (gitignored)
    weekly/<date>/             # Per-week breakdowns (gitignored)
```
