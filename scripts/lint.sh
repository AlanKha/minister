#!/bin/bash

# Minister Lint Script
# Runs static analysis on all Dart packages (app, server, shared)

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

BOLD="\033[1m"
GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[0;33m"
RESET="\033[0m"

exit_code=0

run_analyze() {
    local name="$1"
    local dir="$2"
    local cmd="$3"

    echo ""
    echo -e "${BOLD}Analyzing ${name}...${RESET}"
    echo "────────────────────────────────"

    if output=$($cmd 2>&1); then
        echo -e "${GREEN}No issues found.${RESET}"
    else
        echo "$output" | tail -n +2  # skip the "Analyzing..." header line dart prints
        exit_code=1
    fi
}

echo -e "${BOLD}Minister Lint${RESET}"
echo "════════════════════════════════"

run_analyze "shared" "$PROJECT_ROOT/shared" "dart analyze $PROJECT_ROOT/shared"
run_analyze "server" "$PROJECT_ROOT/server" "dart analyze $PROJECT_ROOT/server"
run_analyze "app"    "$PROJECT_ROOT/app"    "flutter analyze $PROJECT_ROOT/app"

echo ""
echo "════════════════════════════════"
if [ $exit_code -eq 0 ]; then
    echo -e "${GREEN}${BOLD}All clean!${RESET}"
else
    echo -e "${YELLOW}${BOLD}Issues found. See above for details.${RESET}"
fi

exit $exit_code
