#!/bin/bash

# Claude Greeter - Status Script (Mac/Linux)
# Check application status and show recent logs

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo "========================================"
echo "Claude Greeter - Status"
echo "========================================"
echo ""

# Check if PID file exists
if [ ! -f "app.pid" ]; then
    echo -e "${RED}✗ Application is NOT running${NC}"
    echo "  (No PID file found)"
    echo ""
    echo "To start: ./setup.sh"
    exit 1
fi

# Read PID
APP_PID=$(cat app.pid)

# Check if process is running
if ! ps -p $APP_PID > /dev/null 2>&1; then
    echo -e "${RED}✗ Application is NOT running${NC}"
    echo "  (Process $APP_PID not found)"
    rm app.pid
    echo ""
    echo "To start: ./setup.sh"
    exit 1
fi

# Get process info
PROCESS_INFO=$(ps -p $APP_PID -o etime=,pid=,comm= 2>/dev/null)

echo -e "${GREEN}✓ Application is RUNNING${NC}"
echo ""
echo "Process Details:"
echo "  PID: $APP_PID"
echo "  Uptime: $(echo $PROCESS_INFO | awk '{print $1}')"
echo "  Command: $(echo $PROCESS_INFO | awk '{print $3}')"
echo ""

# Check API endpoint
echo "API Status:"
if command -v curl &> /dev/null; then
    API_RESPONSE=$(curl -s http://localhost:8000 2>/dev/null)
    if [ $? -eq 0 ]; then
        echo -e "  ${GREEN}✓ API is responding at http://localhost:8000${NC}"

        # Parse and display key info if jq is available
        if command -v jq &> /dev/null; then
            echo ""
            echo "Schedule Information:"
            echo "$API_RESPONSE" | jq -r '
                "  Status: \(.status)",
                "  Next Run: \(.next_scheduled_run)",
                "  Interval: \(.interval)",
                "  Start Time: \(.start_time)"
            '

            # Show prevent window if exists
            HAS_PREVENT=$(echo "$API_RESPONSE" | jq -r 'has("prevent_window")')
            if [ "$HAS_PREVENT" = "true" ]; then
                echo ""
                echo "Prevent Window (Quiet Hours):"
                echo "$API_RESPONSE" | jq -r '
                    "  Start: \(.prevent_window.start)",
                    "  End: \(.prevent_window.end)",
                    "  Currently Active: \(.prevent_window.active)"
                '
            fi
        else
            echo "  Response: $API_RESPONSE"
        fi
    else
        echo -e "  ${YELLOW}! API is not responding${NC}"
        echo "  Check logs for details"
    fi
else
    echo "  (curl not available to test API)"
fi

echo ""
echo "========================================"
echo "Recent Logs (last 20 lines):"
echo "========================================"

# Show recent logs
if [ -f "log/app.log" ]; then
    tail -n 20 log/app.log
else
    echo -e "${YELLOW}No log file found${NC}"
fi

echo ""
echo "========================================"
echo "Useful Commands:"
echo "  ./stop.sh              - Stop application"
echo "  tail -f log/app.log    - Follow live logs"
echo "  curl http://localhost:8000/schedule - Get schedule info"
echo "  curl -X POST http://localhost:8000/greet - Manual trigger"
echo "========================================"
