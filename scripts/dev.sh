#!/bin/bash

# Minister Development Startup Script
# Starts the Dart server and React Native/Expo app on the specified platform
# Usage: ./scripts/dev.sh [macos|web|ios]

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Parse platform argument (default to macos)
PLATFORM="${1:-web}"

# Validate platform
case "$PLATFORM" in
    macos|web|ios)
        ;;
    *)
        echo "❌ Invalid platform: $PLATFORM"
        echo "Usage: ./scripts/dev.sh [macos|web|ios]"
        exit 1
        ;;
esac

echo "🚀 Starting Minister Development Environment ($PLATFORM)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "❌ Docker not found. Install via: brew install colima docker"
    exit 1
fi

# Start Docker daemon if not running (supports Colima and Docker Desktop)
if ! docker ps > /dev/null 2>&1; then
    if command -v colima &> /dev/null; then
        echo "⏳ Starting Colima..."
        colima start
    elif [ -d "/Applications/Docker.app" ]; then
        echo "⏳ Starting Docker Desktop..."
        open /Applications/Docker.app
        sleep 10
    else
        echo "❌ Docker daemon not running. Start it with: colima start"
        exit 1
    fi

    # Wait for daemon to be ready
    echo "⏳ Waiting for Docker daemon..."
    for i in $(seq 1 20); do
        if docker ps > /dev/null 2>&1; then break; fi
        sleep 1
    done

    if ! docker ps > /dev/null 2>&1; then
        echo "❌ Docker daemon failed to start."
        exit 1
    fi
fi

# Check if npx/node is available
if ! command -v node &> /dev/null; then
    echo "❌ Node.js not found. Install from https://nodejs.org"
    exit 1
fi

# Start the server in Docker
echo ""
echo "📦 Starting Dart server in Docker..."
echo "   Server will be available at http://localhost:3000"
cd "$PROJECT_ROOT"

# Setup cleanup on exit
cleanup() {
    echo ""
    echo "🧹 Shutting down development environment..."
    cd "$PROJECT_ROOT"
    docker-compose down
}
trap cleanup EXIT

docker-compose up --build -d

# Wait for server to be healthy
echo "⏳ Waiting for server to be ready..."
max_attempts=30
attempt=0
while [ $attempt -lt $max_attempts ]; do
    if curl -f http://localhost:3000/api/accounts > /dev/null 2>&1; then
        echo "✅ Server is ready!"
        break
    fi
    sleep 1
    attempt=$((attempt + 1))
done

if [ $attempt -eq $max_attempts ]; then
    echo "⚠️  Server may not be responding. Check with: docker-compose logs"
fi

# Start the Expo/React Native app
echo ""
cd "$PROJECT_ROOT/app"

case "$PLATFORM" in
    macos)
        # Check for full Xcode.app (Command Line Tools alone aren't enough)
        if [ -d "/Applications/Xcode.app" ] || xcodebuild -version &> /dev/null 2>&1; then
            echo "📱 Starting React Native macOS app (native)..."
            echo ""
            # Run pod install if Pods directory is missing or out of date
            if [ ! -f "$PROJECT_ROOT/app/macos/Pods/Manifest.lock" ]; then
                echo "⏳ Installing CocoaPods dependencies..."
                cd "$PROJECT_ROOT/app/macos" && pod install
                cd "$PROJECT_ROOT/app"
            fi
            npx react-native run-macos
        else
            echo "⚠️  Xcode.app not found — native macOS build unavailable."
            echo "   Install Xcode from the App Store, then run: ./scripts/dev.sh macos"
            echo ""
            echo "🌐 Starting Expo dev server (web preview) instead..."
            echo "   Open http://localhost:8081 in your browser"
            echo ""
            npx expo start --web
        fi
        ;;
    web)
        echo "🌐 Starting Expo web app..."
        echo ""
        npx expo start --web
        ;;
    ios)
        echo "📱 Starting Expo iOS app..."
        echo ""
        npx expo run:ios
        ;;
esac

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Development environment closed!"
echo ""
