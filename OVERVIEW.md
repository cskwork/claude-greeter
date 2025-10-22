# Claude Agent Greeter - Project Overview

## What This Does

A lightweight FastAPI server that automatically greets Claude every 5 hours using the Claude Agent SDK.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    FastAPI Server (main.py)                  │
│                                                               │
│  ┌───────────────────────────────────────────────────────┐  │
│  │           APScheduler (Background)                     │  │
│  │                                                         │  │
│  │  ┌─────────────┐         Every 5 hours from START_TIME│  │
│  │  │  09:00 ────▶ greet_agent()                         │  │
│  │  │  14:00 ────▶ greet_agent()                         │  │
│  │  │  19:00 ────▶ greet_agent()                         │  │
│  │  │  00:00 ────▶ greet_agent()                         │  │
│  │  └─────────────┘                                        │  │
│  └───────────────────────────────────────────────────────┘  │
│                           │                                  │
│                           ▼                                  │
│  ┌───────────────────────────────────────────────────────┐  │
│  │         Claude Agent SDK                               │  │
│  │         query(prompt="Hi!", options=...)              │  │
│  └───────────────────────────────────────────────────────┘  │
│                           │                                  │
└───────────────────────────┼──────────────────────────────────┘
                            ▼
                ┌───────────────────────┐
                │   Claude API          │
                │   (Anthropic)         │
                └───────────────────────┘
```

## Request Flow

### Scheduled Greeting (Automatic)
```
Timer triggers ──▶ greet_agent() ──▶ Claude Agent SDK ──▶ Anthropic API
                                                              │
                        ◀──── Response ◀────────────────────┘
                        │
                        ▼
                   Console log
```

### Manual Greeting (HTTP)
```
POST /greet ──▶ greet_agent() ──▶ Claude Agent SDK ──▶ Anthropic API
                                                           │
                     ◀──── Response ◀─────────────────────┘
                     │
                     ▼
                 JSON response
```

## Components

### 1. main.py (Core Application)
- FastAPI server on port 8000
- APScheduler for time-based triggers
- Claude Agent SDK integration
- Three endpoints: /, /greet, /schedule

### 2. .env (Configuration)
```
ANTHROPIC_API_KEY    → Your API credentials
START_TIME           → When to begin 5-hour cycles (HH:MM)
TIMEZONE (optional)  → Timezone for scheduling
```

### 3. requirements.txt (Dependencies)
- fastapi → Web framework
- uvicorn → ASGI server
- apscheduler → Scheduling engine
- claude-agent-sdk → Claude integration
- python-dotenv → Config management

### 4. test_setup.py (Verification)
- Checks Python version (3.10+)
- Verifies Claude Code CLI installed
- Validates .env configuration
- Tests Claude SDK connection

## Key Features

### Smart Scheduling
Calculates next run based on START_TIME:
- Start before 09:00 → First run at 09:00
- Start at 11:30 → First run at 14:00
- Continuous 5-hour intervals forever

### Three Access Methods
1. **Automatic** - Scheduled background task
2. **Manual API** - POST /greet (instant trigger)
3. **Status Check** - GET / (health + next run)

### Cross-Platform
Works on:
- macOS (Intel/Apple Silicon)
- Windows (10/11)
- Linux (Ubuntu, etc.)

Uses system time by default, customizable via TIMEZONE.

## Data Flow

```
.env file
   │
   ├─▶ ANTHROPIC_API_KEY ──▶ Claude Agent SDK
   ├─▶ START_TIME ──────────▶ Scheduler calculation
   └─▶ TIMEZONE ────────────▶ Scheduler timezone
```

## Example Session

```bash
$ python main.py
============================================================
Claude Agent Greeter API
============================================================
Start time: 09:00
Interval: Every 5 hours
Timezone: System default
============================================================
INFO:     Uvicorn running on http://0.0.0.0:8000
Scheduling first greeting at: 2025-10-23 09:00:00
Scheduler started. Next run: 2025-10-23 09:00:00

[2025-10-23 09:00:00] Greeting Claude agent...
[2025-10-23 09:00:02] Claude responded: Hello! Nice to hear from you...

[2025-10-23 14:00:00] Greeting Claude agent...
[2025-10-23 14:00:03] Claude responded: Hi there! How can I help?
```

## Customization Points

### Change Interval
```python
# main.py line 113
trigger=IntervalTrigger(hours=5, ...)  # Change 5 to any number
```

### Change Greeting
```python
# main.py line 38
async for message in query(prompt="Hi!", ...):  # Change "Hi!"
```

### Add System Instructions
```python
# main.py line 31
options = ClaudeAgentOptions(
    system_prompt="Your custom instructions here",
    max_turns=1
)
```

### Change Port
```python
# main.py line 159
uvicorn.run(app, host="0.0.0.0", port=8000)  # Change 8000
```

## Files Included

1. **main.py** - FastAPI application with scheduler
2. **.env.example** - Configuration template
3. **requirements.txt** - Python dependencies
4. **README.md** - Full documentation
5. **QUICKSTART.md** - Fast setup guide
6. **test_setup.py** - Setup verification script
7. **OVERVIEW.md** - This file

## Security Notes

- API key in .env (never commit to git)
- No authentication on API (add if exposing publicly)
- Runs on localhost by default
- No data persistence (stateless)

## Performance

- Minimal resource usage (~50MB RAM)
- Single Python process
- Async/await for efficiency
- No database required

## Limitations

- No persistence between restarts
- Schedule resets on server restart
- Single instance only (no clustering)
- Manual trigger doesn't affect schedule

## Next Steps

1. Run `test_setup.py` to verify prerequisites
2. Edit `.env` with your API key
3. Run `python main.py`
4. Check http://localhost:8000
5. Wait for scheduled greeting or POST to /greet

---

Built with Claude Agent SDK 0.1.0
