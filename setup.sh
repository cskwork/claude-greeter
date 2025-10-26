#!/bin/bash

# Claude Greeter - Automated Setup Script (Mac/Linux)
# This script installs dependencies and runs the application in background

set -e  # Exit on error

echo "========================================"
echo "Claude Greeter - Setup Script"
echo "========================================"
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Check Python3
echo -e "${YELLOW}[1/6] Checking Python installation...${NC}"
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}Error: Python3 is not installed${NC}"
    echo "Please install Python3:"
    echo "  Mac: brew install python3"
    echo "  Linux: sudo apt-get install python3 python3-pip python3-venv"
    exit 1
fi
PYTHON_VERSION=$(python3 --version)
echo -e "${GREEN}✓ Found: $PYTHON_VERSION${NC}"
echo ""

# Create virtual environment
echo -e "${YELLOW}[2/6] Setting up virtual environment...${NC}"
if [ ! -d "venv" ]; then
    echo "Creating new virtual environment..."
    python3 -m venv venv
    echo -e "${GREEN}✓ Virtual environment created${NC}"
else
    echo -e "${GREEN}✓ Virtual environment already exists${NC}"
fi
echo ""

# Activate virtual environment
echo -e "${YELLOW}[3/6] Activating virtual environment...${NC}"
source venv/bin/activate
echo -e "${GREEN}✓ Virtual environment activated${NC}"
echo ""

# Install dependencies
echo -e "${YELLOW}[4/6] Installing Python dependencies...${NC}"
pip install --upgrade pip -q
pip install -r requirements.txt -q
echo -e "${GREEN}✓ Dependencies installed${NC}"
echo ""

# Setup .env file
echo -e "${YELLOW}[5/6] Configuring environment...${NC}"
if [ ! -f ".env" ]; then
    if [ -f ".env.example" ]; then
        cp .env.example .env
        echo -e "${GREEN}✓ Created .env from .env.example${NC}"
        echo -e "${YELLOW}! Please edit .env to configure START_TIME and other settings${NC}"
    else
        echo -e "${RED}Warning: .env.example not found${NC}"
        echo "Creating default .env..."
        cat > .env << EOF
# Start time in 24-hour format (HH:MM) - will run every 5 hours from this time
START_TIME=09:00

# Optional: Timezone (defaults to system timezone)
# TIMEZONE=Asia/Seoul

# Optional: Prevent window - skip job execution during these hours
# Format: HH:MM (24-hour format)
# Example: PREVENT_START_TIME=23:00, PREVENT_END_TIME=04:00 prevents execution from 11 PM to 4 AM
PREVENT_START_TIME=23:00
PREVENT_END_TIME=04:00
EOF
        echo -e "${GREEN}✓ Created default .env${NC}"
    fi
else
    echo -e "${GREEN}✓ .env file already exists${NC}"
fi
echo ""

# Create log directory
mkdir -p log

# Run in background
echo -e "${YELLOW}[6/6] Starting application in background...${NC}"

# Check if already running
if [ -f "app.pid" ]; then
    OLD_PID=$(cat app.pid)
    if ps -p $OLD_PID > /dev/null 2>&1; then
        echo -e "${YELLOW}Application is already running (PID: $OLD_PID)${NC}"
        echo "To restart, first run: ./stop.sh"
        exit 0
    else
        rm app.pid
    fi
fi

# Start with nohup
nohup python3 main.py > log/app.log 2>&1 &
APP_PID=$!
echo $APP_PID > app.pid

# Wait a moment and check if process started
sleep 2
if ps -p $APP_PID > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Application started successfully!${NC}"
    echo ""
    echo "========================================"
    echo "Setup Complete!"
    echo "========================================"
    echo "Process ID: $APP_PID"
    echo "Log file: log/app.log"
    echo "API: http://localhost:8000"
    echo ""
    echo "Useful commands:"
    echo "  ./stop.sh     - Stop the application"
    echo "  ./status.sh   - Check application status"
    echo "  tail -f log/app.log - View live logs"
    echo ""
    echo "Test endpoints:"
    echo "  curl http://localhost:8000"
    echo "  curl -X POST http://localhost:8000/greet"
    echo "========================================"
else
    echo -e "${RED}✗ Failed to start application${NC}"
    echo "Check log/app.log for errors"
    rm app.pid
    exit 1
fi
