# Quick Start Guide

## 1-Minute Setup

### Step 1: Install Node.js
**Mac:** `brew install node`  
**Windows:** Download from nodejs.org

### Step 2: Install Claude Code CLI
```bash
npm install -g @anthropic-ai/claude-code
```

### Step 3: Setup Project
```bash
# Create virtual environment
python3 -m venv venv

# Activate (Mac/Linux)
source venv/bin/activate

# Activate (Windows)
venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
```

### Step 4: Configure .env
Edit `.env` file:
```env
ANTHROPIC_API_KEY=your_actual_key_here
START_TIME=09:00
```

### Step 5: Test Setup (Optional)
```bash
python test_setup.py
```

### Step 6: Run!
```bash
python main.py
```

## Verification

Visit: http://localhost:8000

You should see:
```json
{
  "status": "running",
  "next_scheduled_run": "2025-10-23 14:00:00",
  "interval": "Every 5 hours"
}
```

## Manual Test

Trigger greeting without waiting:
```bash
curl -X POST http://localhost:8000/greet
```

## What Happens

- Server starts
- Calculates next 5-hour interval from your START_TIME
- Greets Claude automatically every 5 hours
- Logs each interaction to console

## Files

- `main.py` - Main application
- `.env` - Your configuration
- `requirements.txt` - Dependencies
- `README.md` - Full documentation
- `test_setup.py` - Setup verification
- `QUICKSTART.md` - This file

Done! 🎉
