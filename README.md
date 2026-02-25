# Minister

Minister is a personal finance tracker powered by Stripe Financial Connections. It provides a comprehensive view of your finances by pulling bank transactions, automatically categorizing spending using smart rules, and displaying insightful weekly breakdowns.

## ✨ Features

- **Bank Integration** — Securely link bank accounts using Stripe Financial Connections.
- **Auto-Categorization** — ~180 regex-based rules to automatically clean and categorize transactions.
- **Spending Analytics** — Interactive charts showing spending by category and weekly trends.
- **Transaction Management** — Search, filter, and manually override categories for any transaction.
- **Cross-Platform** — Built with React Native/Expo for macOS, iOS, and Web.
- **Local Store** — Efficient JSON-based storage for processed data.

## 🛠 Tech Stack

### Frontend (React Native / Expo)

- **Framework:** Expo SDK 54 with React Native 0.81
- **Navigation:** React Navigation v7 (Drawer with permanent 220px sidebar)
- **State Management:** Zustand v5 (filter & sync state)
- **Data Fetching:** TanStack Query v5
- **Charts:** Victory Native v41
- **Styling:** NativeWind v4 (TailwindCSS)
- **Fonts:** Sora via Expo Google Fonts

### Backend (Node.js / TypeScript)

- **Framework:** Hono v4 on Node.js
- **Integration:** Stripe API (Financial Connections)
- **Data Processing:** Regex-based cleaning and categorization service
- **Storage:** File-based JSON store

## 🏗 Architecture

The project is organized into two main directories:

- **`app/`** — The React Native/Expo interface. Cross-platform (macOS, iOS, Web).
- **`server/`** — The Node.js/Hono backend (default port 3000) that handles Stripe OAuth flows, transaction fetching, processing, and data storage using JSON files.

## 🚀 Getting Started

### 1. Prerequisites

- [Node.js](https://nodejs.org) v20+
- [Docker](https://docs.docker.com/get-started/get-docker/) (or [Colima](https://github.com/abiosoft/colima))
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

#### Option A: Run with Docker (Recommended)

```bash
docker-compose up
```

The server will start on `http://localhost:3000`. Your data will persist in a Docker volume.

#### Option B: Run Locally with Node.js

```bash
cd server
npm install
npm run dev
```

### 4. App Setup

Install dependencies:

```bash
cd app && npm install
```

Launch the application:

```bash
cd app && npx expo start --web    # Web
cd app && npx react-native run-macos   # macOS (requires Xcode)
cd app && npx expo run:ios        # iOS Simulator/Device
```

Or use the dev script to start everything at once:

```bash
./scripts/dev.sh web     # Web (default)
./scripts/dev.sh macos   # macOS native
./scripts/dev.sh ios     # iOS
```

## 📡 API Endpoints

The server exposes the following REST API:

### Transactions

- `GET /api/transactions` — Fetch cleaned transactions with support for filtering (`account`, `category`, `startDate`, `endDate`, `search`), sorting, and pagination.
- `PATCH /api/transactions/<id>` — Manually override a transaction's category.

### Accounts

- `GET /api/accounts` — List all linked bank accounts.

### Balances

- `GET /api/balances` — Get current account balances.

### Sync

- `POST /api/sync` — Trigger a fresh sync with Stripe to pull latest transactions.

### Analytics

- `GET /api/analytics/summary` — Get spending totals grouped by category.
- `GET /api/analytics/weekly` — Get weekly spending breakdowns.

### Categories

- `GET /api/categories` — List user-defined categorization rules.
- `POST /api/categories` — Create a new rule.
- `PUT /api/categories/<id>` — Update an existing rule.
- `DELETE /api/categories/<id>` — Delete a rule.
- `GET /api/transactions/uncategorized` — List uncategorized transactions.
- `POST /api/transactions/<id>/categorize` — Categorize a transaction (optionally create a rule).

### Settings

- `GET /api/settings` — Get app settings.
- `PUT /api/settings` — Update app settings.

## 📁 File Structure

```text
app/                           # React Native/Expo app
  ├── src/
  │   ├── api/                 # Typed API client
  │   ├── components/          # Reusable UI components
  │   ├── hooks/               # TanStack Query data hooks
  │   ├── models/              # TypeScript data models
  │   ├── navigation/          # Drawer navigation & sidebar
  │   ├── screens/             # App screens (Dashboard, Transactions, etc.)
  │   ├── stores/              # Zustand state stores
  │   ├── theme/               # Colors & typography
  │   └── utils/               # Utility functions
  ├── App.tsx                  # App entry point
  ├── app.json                 # Expo configuration
  └── package.json             # App dependencies

server/                        # Node.js/Hono backend
  ├── src/
  │   ├── routes/              # REST API endpoints
  │   ├── services/            # Business logic (Sync, Analytics, Cleaning)
  │   ├── store/               # File-based JSON storage
  │   ├── config.ts            # Environment configuration
  │   ├── stripe.ts            # Stripe API integration
  │   └── index.ts             # Server entry point
  ├── data/                    # Local storage (gitignored)
  ├── default_category_rules.json  # ~180 built-in categorization rules
  └── package.json             # Server dependencies

docker-compose.yaml           # Docker setup for the server
Dockerfile.server             # Docker build for the server
scripts/
  ├── dev.sh                  # Start full dev environment
  └── lint.sh                 # Run type checking across packages
```

## 🧹 Linting

Run TypeScript type checking across both packages with:

```bash
./scripts/lint.sh
```

This runs `tsc --noEmit` on `server/` and `app/`. The script exits non-zero if any type errors are found, making it suitable for CI pipelines.

## 🔒 Security

- Sensitive keys should be stored in environment variables, never committed to the repository.
- A `.env.example` file is provided as a template.
- The `server/data/` directory is gitignored to prevent leaking personal financial data.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
