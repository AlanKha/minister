# Minister

Minister is a personal finance tracker powered by Stripe Financial Connections. It provides a comprehensive view of your finances by pulling bank transactions, automatically categorizing spending using smart rules, and displaying insightful weekly breakdowns.

## ✨ Features

- **Bank Integration** — Securely link bank accounts using Stripe Financial Connections.
- **Auto-Categorization** — ~180 regex-based rules to automatically clean and categorize transactions.
- **Spending Analytics** — Interactive charts showing spending by category and weekly trends.
- **Transaction Management** — Search, filter, and manually override categories for any transaction.
- **Cross-Platform** — Built with Flutter for iOS, macOS, and Web.
- **Local Store** — Efficient JSON-based storage for processed data.

## 🛠 Tech Stack

### Frontend (Flutter App)

- **State Management:** Riverpod (ProviderScope, ConsumerWidget)
- **Navigation:** go_router
- **Charts:** fl_chart
- **Styling:** Custom Material Design 3 theme
- **Icons:** Cupertino Icons & Material Icons

### Backend (Dart Server)

- **Server Framework:** Shelf (shelf_router, shelf_static)
- **Integration:** Stripe API (Financial Connections)
- **Data Processing:** Regex-based cleaning and categorization service
- **Storage:** File-based JSON store

## 🏗 Architecture

The project is split into two main components:

- **Root (App)** — A Flutter application that serves as the user interface.
- **`server/`** — A Dart shelf HTTP server (default port 3000) that handles Stripe OAuth flows, transaction fetching, processing, and data persistence.
- **`server/data/`** — Acts as a simple database using JSON files for transactions, account mappings, and analytics.

## 🚀 Getting Started

### 1. Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable)
- [Dart SDK](https://dart.dev/get-started/sdk)
- Stripe Account (for Financial Connections keys)

### 2. Server Setup

Navigate to the server directory and install dependencies:

```bash
cd server
dart pub get
```

Set up your Stripe environment variables:

```bash
export stripe_env=sandbox
export stripe_sandbox_secret_key=sk_test_...
export stripe_sandbox_publishable_key=pk_test_...
```

Run the server:

```bash
dart run bin/server.dart
```

### 3. App Setup

From the project root:

```bash
flutter pub get
```

Launch the application:

```bash
flutter run -d chrome    # Web
flutter run -d macos     # macOS (requires Xcode)
flutter run -d ios       # iOS Simulator/Device
```

## 📡 API Endpoints

The server exposes the following REST API:

### Transactions

- `GET /api/transactions` — Fetch cleaned transactions with support for filtering (`account`, `category`, `startDate`, `endDate`, `search`), sorting, and pagination.
- `PATCH /api/transactions/<id>` — Manually override a transaction's category.

### Accounts

- `GET /api/accounts` — List all linked bank accounts.

### Sync

- `POST /api/sync` — Trigger a fresh sync with Stripe to pull latest transactions.

### Analytics

- `GET /api/analytics/summary` — Get spending totals grouped by category.
- `GET /api/analytics/weekly` — Get weekly spending breakdowns.

## 📁 File Structure

```text
lib/                           # Flutter app source
  ├── api/                     # API client & networking
  ├── models/                  # Data models (Account, Transaction, etc.)
  ├── providers/               # Riverpod state providers
  ├── screens/                 # Main UI screens (Dashboard, Transactions, etc.)
  └── widgets/                 # Reusable UI components
server/
  ├── bin/server.dart          # Server entry point
  ├── lib/
  │   ├── routes/              # shelf_router API routes
  │   ├── services/            # Business logic (Sync, Analytics, Cleaning)
  │   └── store/               # JSON file I/O operations
  └── data/                    # Local storage (Gitignored)
```

## 🔒 Security

- Sensitive keys should be stored in environment variables, never committed to the repository.
- A `.env.example` file is provided as a template.
- The `server/data/` directory is gitignored to prevent leaking personal financial data.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
