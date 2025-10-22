# Claude Agent Greeter API

Minimal scheduled API that greets Claude agent every 5 hours using Claude Agent SDK.

## Features

- ✅ Runs every 5 hours from your designated start time
- ✅ Cross-platform (Windows/Mac/Linux)
- ✅ Manual trigger endpoint
- ✅ Schedule monitoring
- ✅ Configurable via .env

## Prerequisites

### 1. Install Node.js (for Claude Code CLI)
- **Mac**: `brew install node`
- **Windows**: Download from [nodejs.org](https://nodejs.org)

### 2. Install Claude Code CLI
```bash
npm install -g @anthropic-ai/claude-code
```

### 3. Get Anthropic API Key
Get your API key from: https://console.anthropic.com/

## Installation

### 1. Clone/Download Project
```bash
cd claude-greeter
```

### 2. Create Virtual Environment

**Mac/Linux:**
```bash
python3 -m venv venv
source venv/bin/activate
```

**Windows:**
```bash
python -m venv venv
venv\Scripts\activate
```

### 3. Install Dependencies
```bash
pip install -r requirements.txt
```

### 4. Configure .env File
Edit the `.env` file:

```env
# Your Anthropic API key (required)
ANTHROPIC_API_KEY=sk-ant-xxxxx

# Start time in 24-hour format (required)
START_TIME=09:00

# Optional: Timezone (uses system timezone if not set)
# TIMEZONE=America/New_York
```

**Common Timezones:**
- America/New_York
- America/Los_Angeles
- Europe/London
- Asia/Tokyo

## Usage

### Start the Server

```bash
python main.py
```

Output:
```
============================================================
Claude Agent Greeter API
============================================================
Start time: 09:00
Interval: Every 5 hours
Timezone: System default
============================================================
INFO:     Started server process
INFO:     Uvicorn running on http://0.0.0.0:8000
Scheduling first greeting at: 2025-10-23 09:00:00
Scheduler started. Next run: 2025-10-23 09:00:00
```

### API Endpoints

#### 1. Health Check
```bash
curl http://localhost:8000/
```

Response:
```json
{
  "status": "running",
  "message": "Claude Agent Greeter is active",
  "next_scheduled_run": "2025-10-23 14:00:00",
  "interval": "Every 5 hours",
  "start_time": "09:00"
}
```

#### 2. Manual Greeting (doesn't affect schedule)
```bash
curl -X POST http://localhost:8000/greet
```

Response:
```json
{
  "status": "success",
  "response": "Hello! Nice to hear from you. How can I help you today?"
}
```

#### 3. View Schedule
```bash
curl http://localhost:8000/schedule
```

Response:
```json
{
  "job_id": "greet_agent_job",
  "job_name": "Greet Claude Agent",
  "next_run_time": "2025-10-23 14:00:00",
  "trigger": "interval[0:05:00:00]",
  "interval_hours": 5,
  "start_time_config": "09:00"
}
```

## How It Works

### Schedule Logic
If you set `START_TIME=09:00`:
- First run: 09:00
- Second run: 14:00 (09:00 + 5 hours)
- Third run: 19:00 (14:00 + 5 hours)
- Fourth run: 00:00 (19:00 + 5 hours, next day)
- Fifth run: 05:00 (00:00 + 5 hours)
- Cycle continues...

### Startup Behavior
- If started **before** 09:00 → waits until 09:00
- If started **after** 09:00 → calculates next 5-hour interval

Example: Start at 11:30
- Next run: 14:00 (first interval after start)
- Then: 19:00, 00:00, 05:00, 09:00...

## Running in Background

### Mac/Linux (using screen)
```bash
screen -S claude-greeter
python main.py
# Press Ctrl+A then D to detach

# To reattach:
screen -r claude-greeter
```

### Mac/Linux (using nohup)
```bash
nohup python main.py > greeter.log 2>&1 &
# Check logs:
tail -f greeter.log
```

### Windows (using pythonw)
```bash
start /B pythonw main.py
```

### Using System Services

**Mac (launchd):** Create `~/Library/LaunchAgents/com.claude.greeter.plist`
**Linux (systemd):** Create service file in `/etc/systemd/system/`
**Windows (Task Scheduler):** Create scheduled task

## Logs

Console output shows each greeting:
```
[2025-10-23 09:00:00] Greeting Claude agent...
[2025-10-23 09:00:03] Claude responded: Hello! Nice to hear from you. How can I help you today?
```

## Troubleshooting

### "claude-code not found"
```bash
# Reinstall Claude Code CLI
npm install -g @anthropic-ai/claude-code

# Verify installation
claude-code --version
```

### "ANTHROPIC_API_KEY not found"
- Ensure `.env` file exists in project root
- Check API key is valid: https://console.anthropic.com/

### Timezone Issues
- List available timezones:
```python
import pytz
print(pytz.all_timezones)
```
- Or use system timezone (leave TIMEZONE empty)

### Port 8000 Already in Use
Change port in main.py:
```python
uvicorn.run(app, host="0.0.0.0", port=8001)
```

## Project Structure

```
claude-greeter/
├── main.py              # FastAPI app with scheduler
├── requirements.txt     # Python dependencies
├── .env                 # Configuration (API key, start time)
└── README.md           # This file
```

## Customization

### Change Greeting Message
Edit `main.py` line 38:
```python
async for message in query(prompt="Hi!", options=options):
```

### Change Interval
Edit `main.py` line 113:
```python
trigger=IntervalTrigger(hours=5, start_date=next_run),
# Change hours=5 to your desired interval
```

### Add More System Instructions
Edit `main.py` line 31:
```python
options = ClaudeAgentOptions(
    system_prompt="You are a friendly assistant. Keep responses brief.",
    max_turns=1
)
```

## Related Concepts

This project combines 3 key patterns:

1. **Scheduled Tasks** - APScheduler manages time-based execution
2. **REST APIs** - FastAPI provides HTTP endpoints for monitoring/control
3. **Agent Integration** - Claude Agent SDK enables programmatic AI interaction

Similar tools: Cron (Linux), Task Scheduler (Windows), GitHub Actions (CI/CD)

## Next Action

**Run the server**: `python main.py` and watch it greet Claude every 5 hours! 🚀
