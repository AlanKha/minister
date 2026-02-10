# Development Setup

This guide explains how to run Minister locally for development.

## Quick Start (Recommended)

Run the server and macOS app with one command:

```bash
# Make the script executable (first time only)
chmod +x scripts/dev.sh

# Start both server and app
./scripts/dev.sh
```

This will:
1. Start the Dart server (on `http://localhost:3000`)
2. Open the macOS app in the Flutter debugger

## Manual Setup

### Step 1: Start the Server

#### Option A: Docker (Recommended)

```bash
docker-compose up
```

The server starts on `http://localhost:3000` and persists data in a Docker volume.

**Troubleshooting:**
- If you get "Docker daemon not running", open Docker.app from Applications
- If you see warnings about obsolete version, that's fine (it's ignored)

#### Option B: Local Dart

```bash
cd server
dart pub get
dart run bin/server.dart
```

### Step 2: Start the macOS App

In a new terminal:

```bash
cd app
flutter pub get
flutter run -d macos
```

The app will open in a new window and connect to the server at `http://localhost:3000`.

## Directory Structure for Development

```
minister/
├── app/           # Flutter UI - edit screens, widgets, providers here
├── shared/        # Models & config - edit data structures here
├── server/        # Dart backend - edit routes, services here
├── docker-compose.yaml  # Run server in Docker
└── scripts/dev.sh # Quick dev startup
```

## Editing Code

### Frontend Changes (app/)
- Screens: `app/lib/screens/`
- Widgets: `app/lib/widgets/`
- State: `app/lib/providers/`
- Hot reload: Just save the file, it updates in seconds

### Backend Changes (server/)
- Routes: `server/lib/routes/`
- Services: `server/lib/services/`
- Changes require restarting the server

### Shared Models (shared/)
- Models: `shared/lib/models/`
- Changes need `dart pub get` in both app/ and server/

## Common Tasks

### Add a new API endpoint

1. Create route in `server/lib/routes/`
2. Add model to `shared/lib/models/` (if needed)
3. Create API method in `app/lib/api/api_client.dart`
4. Add provider in `app/lib/providers/`
5. Use provider in a screen

### Change the API base URL

Edit `app/lib/config.dart`:
```dart
const apiBaseUrl = 'http://your-server:3000';
```

### Fix linting errors

Run analyzer:
```bash
cd app && dart analyze
cd server && dart analyze
cd shared && dart analyze
```

Automatically fix issues:
```bash
cd app && dart fix --apply
```

## Testing

### Run tests

```bash
cd app
flutter test
```

### Check linting

```bash
dart analyze
```

### Run server in debug mode

```bash
cd server
dart run bin/server.dart  # Watch for changes with:
# dart run bin/server.dart --enable-vm-service
```

## Stopping Everything

- **macOS app**: ⌘Q or close the window
- **Server (Docker)**: `docker-compose down`
- **Server (Local)**: Ctrl+C in terminal

## Environment Variables

Copy `.env.example` to `.env` and add your Stripe keys:

```bash
cp .env.example .env
```

Then edit `.env`:
```env
stripe_env=sandbox
stripe_sandbox_secret_key=sk_test_YOUR_KEY
stripe_sandbox_publishable_key=pk_test_YOUR_KEY
```

## Connecting to Real Bank Accounts

Minister uses Stripe Financial Connections. To test:

1. Get sandbox API keys from Stripe Dashboard
2. Add them to `.env`
3. Run the app and click "Link Account"
4. Use Stripe's test credentials

See [Stripe Financial Connections docs](https://stripe.com/docs/financial-connections) for test credentials.

## Troubleshooting

**"Cannot connect to server"**
- Make sure server is running on port 3000
- Check `http://localhost:3000/api/accounts` in browser

**"Model mismatch" errors**
- Run `dart pub get` in all three directories
- Models in `shared/` changed, need to rebuild both parts

**Docker build fails**
- Make sure Dockerfile.server exists
- Check that `app/pubspec.yaml` is in the right place
- Try `docker system prune -a` to clear cache

**Flutter can't find macOS project**
- Run `flutter clean`
- Run `flutter pub get` from `app/` directory
- Try `flutter run -d macos` explicitly

## Next Steps

- [ARCHITECTURE.md](./ARCHITECTURE.md) — Understand the project structure
- [README.md](./README.md) — Overview and API documentation
