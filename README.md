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

The project is organized into three main directories for clarity and simplicity:

- **`app/`** — The Flutter mobile and web interface. This is what users see and interact with.
- **`shared/`** — Shared data models and configuration used by both the app and server. Think of this as the "data structure" that both parts agree to use.
- **`server/`** — The Dart backend server (default port 3000) that handles Stripe OAuth flows, transaction fetching, processing, and data storage using JSON files.

## 🚀 Getting Started

### 1. Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable)
- [Dart SDK](https://dart.dev/get-started/sdk)
- Stripe Account (for Financial Connections keys)

### 2. Environment Variables

Copy the example environment file:

```bash
cp .env.example .env
```

Edit `.env` with your Stripe keys:

```env
stripe_env=sandbox
stripe_sandbox_secret_key=sk_test_...
stripe_sandbox_publishable_key=pk_test_...
```

### 3. Server Setup (Two Options)

#### Option A: Run with Docker (Recommended for Non-Technical Users)

```bash
docker-compose up
```

The server will start on `http://localhost:3000`. Your data will persist in a Docker volume.

#### Option B: Run Locally with Dart

Navigate to the server directory and install dependencies:

```bash
cd server
dart pub get
```

Run the server:

```bash
dart run bin/server.dart
```

### 4. App Setup

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
app/                           # Flutter mobile/web app
  ├── lib/
  │   ├── api/                 # API client & networking
  │   ├── config.dart          # App configuration (API base URL)
  │   ├── main.dart            # App entry point
  │   ├── providers/           # Riverpod state providers
  │   ├── screens/             # Main UI screens (Dashboard, Transactions, etc.)
  │   ├── widgets/             # Reusable UI components
  │   └── router.dart          # Navigation routing
  ├── ios/                      # iOS-specific files
  ├── macos/                    # macOS-specific files
  ├── web/                      # Web-specific files
  └── pubspec.yaml             # App dependencies

shared/                        # Data models & config (used by both app & server)
  ├── lib/
  │   ├── models/              # Shared data classes (Account, Transaction, Analytics)
  │   └── config/              # Shared configuration (Stripe keys)
  └── pubspec.yaml             # Shared package dependencies

server/                        # Dart backend server
  ├── bin/
  │   └── server.dart          # Server entry point
  ├── lib/
  │   ├── routes/              # REST API endpoints (shelf_router)
  │   ├── services/            # Business logic (Sync, Analytics, Cleaning)
  │   ├── store/               # File-based data storage
  │   ├── stripe_client.dart   # Stripe API integration
  │   └── category_rules.dart  # Transaction categorization rules
  ├── data/                    # Local storage (transactions, accounts - Gitignored)
  ├── public/                  # Static files (if needed)
  └── pubspec.yaml             # Server dependencies

docker-compose.yaml           # Docker setup for running the server
Dockerfile.server             # Docker build instructions for server
```

## 🧹 Linting

Run static analysis across all three packages (shared, server, app) with:

```bash
./scripts/lint.sh
```

This runs `dart analyze` on `shared/` and `server/`, and `flutter analyze` on `app/`. The script exits non-zero if any issues are found, making it suitable for CI pipelines.

## 🔒 Security

- Sensitive keys should be stored in environment variables, never committed to the repository.
- A `.env.example` file is provided as a template.
- The `server/data/` directory is gitignored to prevent leaking personal financial data.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
