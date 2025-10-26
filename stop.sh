#!/bin/bash

# Claude Greeter - Stop Script (Mac/Linux)
# Gracefully stops the background application

set -e

echo "========================================"
echo "Claude Greeter - Stop Script"
echo "========================================"
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Check if PID file exists
if [ ! -f "app.pid" ]; then
    echo -e "${YELLOW}No PID file found. Application may not be running.${NC}"
    exit 0
fi

# Read PID
APP_PID=$(cat app.pid)

# Check if process is running
if ! ps -p $APP_PID > /dev/null 2>&1; then
    echo -e "${YELLOW}Process (PID: $APP_PID) is not running.${NC}"
    rm app.pid
    exit 0
fi

# Stop the process
echo -e "${YELLOW}Stopping application (PID: $APP_PID)...${NC}"
kill $APP_PID

# Wait for process to stop (max 10 seconds)
COUNTER=0
while ps -p $APP_PID > /dev/null 2>&1 && [ $COUNTER -lt 10 ]; do
    sleep 1
    COUNTER=$((COUNTER + 1))
    echo -n "."
done
echo ""

# Force kill if still running
if ps -p $APP_PID > /dev/null 2>&1; then
    echo -e "${YELLOW}Process did not stop gracefully. Forcing termination...${NC}"
    kill -9 $APP_PID
    sleep 1
fi

# Verify stopped
if ps -p $APP_PID > /dev/null 2>&1; then
    echo -e "${RED}Failed to stop process${NC}"
    exit 1
else
    echo -e "${GREEN}✓ Application stopped successfully${NC}"
    rm app.pid
fi

echo "========================================"
