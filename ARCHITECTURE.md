# Minister Architecture Guide

This document explains how Minister is organized in simple terms.

## Three Main Parts

Think of Minister like a restaurant:

- **`app/`** — The front of the restaurant (the kitchen from a customer's view). This is what users see and interact with.
- **`shared/`** — The menu and kitchen standards. Both the front and back use these to understand each other.
- **`server/`** — The back of the restaurant (the kitchen). It does the real work: talking to banks, organizing receipts, and storing everything.

## Directory Breakdown

### `app/` — The User Interface

This is a **Flutter application** that users download and run. It's the beautiful interface people see.

```
app/
├── lib/
│   ├── screens/          # Full pages (Dashboard, Transactions, Analytics)
│   ├── widgets/          # Small reusable pieces (buttons, cards, charts)
│   ├── providers/        # How data flows between screens
│   ├── api/              # Code that talks to the server
│   └── config.dart       # Settings (like "where is the server?")
├── ios/                  # Code for running on iPhones
├── macos/                # Code for running on Macs
└── web/                  # Code for running in browsers
```

**What it does:**
- Shows banks that are connected
- Lists your transactions
- Displays spending charts
- Lets you search and filter transactions
- Allows you to fix category labels

### `shared/` — The Common Language

This is where data structures live. Both the app and server use these to understand each other.

```
shared/
├── models/               # Data definitions
│   ├── account.dart      # What a bank account looks like
│   ├── transaction.dart  # What a transaction looks like
│   └── analytics.dart    # What spending data looks like
└── config/               # Shared configuration
    └── config.dart       # Stripe API keys and setup
```

**Why it matters:**
- When the app asks for a transaction, the server sends it in the exact format defined here
- No confusion about what fields exist or what types they are
- Both parts stay in sync with one update

### `server/` — The Engine

This is a **Dart web server** that does all the heavy lifting. It runs in the background (on your computer or in Docker).

```
server/
├── bin/
│   └── server.dart       # Where the server starts
├── lib/
│   ├── routes/           # API endpoints (/api/accounts, /api/transactions, etc.)
│   ├── services/         # Business logic
│   │   ├── sync_service.dart        # Talks to Stripe, gets new transactions
│   │   ├── cleaning_service.dart    # Cleans up transaction data
│   │   └── analytics_service.dart   # Calculates spending summaries
│   ├── store/            # Reads/writes files (the database)
│   ├── stripe_client.dart # Talks to Stripe's API
│   └── category_rules.dart # Rules for auto-categorizing transactions
└── data/                 # Where all your data is stored (JSON files)
```

**What it does:**
- Connects to Stripe and downloads your transactions
- Cleans up the data (removes unnecessary fields)
- Auto-categorizes transactions using smart rules
- Stores everything in files on your computer
- Serves data to the app when it asks

## How They Work Together

1. **User opens the app** → app asks server for transactions
2. **Server receives request** → checks what you asked for (filters, sorting, etc.)
3. **Server reads from disk** → looks through stored transaction files
4. **Server sends back data** → uses the shared format so app understands it
5. **App displays it** → renders transactions in beautiful UI

## Running Minister

### For Beginners (Docker)

Don't install anything complicated. Just run:

```bash
docker-compose up
```

This starts the server in a container. Your app connects to `http://localhost:3000`.

### For Developers

Run the server directly:

```bash
cd server
dart pub get
dart run bin/server.dart
```

Then run the app:

```bash
cd app
flutter pub get
flutter run -d chrome
```

## Key Concepts

**Models** — Data structures. Think of them like blueprints for objects (accounts, transactions).

**Providers** — In the app, these manage state and make data available to screens.

**Routes** — Endpoints the server exposes. Each route does one thing (`/api/transactions`, `/api/accounts`, etc.).

**Services** — The server's brain. These contain the actual business logic.

**Store** — How data is saved. Currently uses JSON files on disk.

## Why This Structure?

✅ **Easy to Understand** — Clear separation: interface, shared data, backend

✅ **Easy to Modify** — Want to change a screen? Edit `app/`. Want to add API logic? Edit `server/`.

✅ **Easy to Deploy** — The `Dockerfile.server` and `docker-compose.yaml` make it simple to self-host

✅ **Easy to Share Code** — Models live in `shared/`, so app and server never get out of sync

## Questions?

- **Why Dart everywhere?** Single language means less context switching, faster development
- **Why JSON files instead of a database?** Simple to understand, no database setup needed, good for self-hosting
- **Why Flutter?** Works on iOS, Android, Web, Mac, Windows from one codebase
- **Why Shelf?** Lightweight, fast, perfect for a small backend service
