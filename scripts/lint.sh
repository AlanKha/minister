#!/bin/bash

# Minister Lint Script
# Runs TypeScript type checking on all packages (app, server)

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

BOLD="\033[1m"
GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[0;33m"
RESET="\033[0m"

exit_code=0

run_typecheck() {
    local name="$1"
    local dir="$2"

    echo ""
    echo -e "${BOLD}Type-checking ${name}...${RESET}"
    echo "────────────────────────────────"

    if output=$(cd "$dir" && npx tsc --noEmit 2>&1); then
        echo -e "${GREEN}No issues found.${RESET}"
    else
        echo "$output"
        exit_code=1
    fi
}

echo -e "${BOLD}Minister Lint${RESET}"
echo "════════════════════════════════"

run_typecheck "server" "$PROJECT_ROOT/server"
run_typecheck "app"    "$PROJECT_ROOT/app"

echo ""
echo "════════════════════════════════"
if [ $exit_code -eq 0 ]; then
    echo -e "${GREEN}${BOLD}All clean!${RESET}"
else
    echo -e "${YELLOW}${BOLD}Issues found. See above for details.${RESET}"
fi

exit $exit_code
