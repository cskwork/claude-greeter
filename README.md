# Claude Agent Greeter API

Minimal scheduled API that greets the Claude agent every 5 hours using the Claude Agent SDK.

## Features

- ✅ **Automated Setup**: `setup.sh` and `setup.bat` scripts for easy installation.
- ✅ **Scheduled Execution**: Runs every 5 hours from your designated start time.
- ✅ **Quiet Hours**: Configure a "prevent window" to skip jobs during specific hours.
- 🔄 **Schedule Reset**: Automatically resets the schedule to the next day's `START_TIME` if a run is skipped during quiet hours.
- ✅ **Robust & Resilient**: Includes retry logic with exponential backoff for API calls.
- ✅ **Cross-Platform**: Works on Windows, macOS, and Linux.
- ✅ **Easy Management**: Scripts to start, stop, and check the status of the application.
- ✅ **Manual Trigger**: An API endpoint to trigger a greeting manually.
- ✅ **Schedule Monitoring**: An API endpoint to view the current schedule.

## Prerequisites

1.  **Python**: Version 3.8 or higher.
2.  **Node.js (for Claude Code CLI)**:
    *   **Mac**: `brew install node`
    *   **Windows**: Download from [nodejs.org](https://nodejs.org)
3.  **Claude Code CLI**:
    ```bash
    npm install -g @anthropic-ai/claude-code
    ```
4.  **Anthropic API Key**: Get your API key from [console.anthropic.com](https://console.anthropic.com/).

## Quick Start

1.  **Clone the project**:
    ```bash
    git clone <repository-url>
    cd claude-greeter
    ```

2.  **Run the setup script**:
    *   **Mac/Linux**:
        ```bash
        chmod +x setup.sh
        ./setup.sh
        ```
    *   **Windows**:
        ```bat
        setup.bat
        ```

    The setup script will:
    - Create a Python virtual environment (`venv`).
    - Install all required dependencies.
    - Create a `.env` file from the `.env.example` template.
    - Start the application in the background.

3.  **Configure your environment**:
    Edit the `.env` file to set your `ANTHROPIC_API_KEY` and customize the `START_TIME`.

    ```env
    # Your Anthropic API key (required)
    ANTHROPIC_API_KEY=sk-ant-xxxxx

    # Start time in 24-hour format (HH:MM) - will run every 5 hours from this time
    START_TIME=09:00

    # Optional: Timezone (defaults to system timezone)
    # TIMEZONE=America/New_York

    # Optional: Prevent window - skip job execution during these hours
    # Format: HH:MM (24-hour format)
    # Example: PREVENT_START_TIME=23:00, PREVENT_END_TIME=04:00 prevents execution from 11 PM to 4 AM
    PREVENT_START_TIME=23:00
    PREVENT_END_TIME=04:00
    ```

## Management

Use the following scripts to manage the application:

-   **Check Status**:
    -   `./status.sh` (Mac/Linux)
    -   `status.bat` (Windows)
-   **Stop the Application**:
    -   `./stop.sh` (Mac/Linux)
    -   `stop.bat` (Windows)
-   **View Logs**:
    ```bash
    tail -f log/app.log
    ```

## API Endpoints

#### 1. Health Check
```bash
curl http://localhost:8000/
```
*Response:*
```json
{
  "status": "running",
  "message": "Claude Agent Greeter is active",
  "next_scheduled_run": "2025-10-29T14:00:00+09:00",
  "interval": "Every 5 hours",
  "start_time": "09:00",
  "prevent_window": {
    "start": "23:00",
    "end": "04:00",
    "active": false
  }
}
```

#### 2. Manual Greeting
Triggers a greeting without affecting the schedule.
```bash
curl -X POST http://localhost:8000/greet
```
*Response:*
```json
{
  "status": "success",
  "response": "Hello! Nice to hear from you. How can I help you today?",
  "elapsed_seconds": 3.2
}
```

#### 3. View Schedule
```bash
curl http://localhost:8000/schedule
```
*Response:*
```json
{
  "job_id": "greet_agent_job",
  "job_name": "Greet Claude Agent",
  "next_run_time": "2025-10-29T14:00:00+09:00",
  "trigger": "interval[5:00:00]",
  "interval_hours": 5,
  "start_time_config": "09:00"
}
```

## Customization

To customize the application's behavior, edit `main.py`:

-   **Greeting Message**: Modify the `prompt` in the `greet_agent` function.
-   **Interval**: Change the `hours` parameter in the `IntervalTrigger` inside the `lifespan` function.
-   **System Instructions**: Update the `system_prompt` in the `ClaudeAgentOptions` within the `greet_agent` function.

## Project Structure

```
claude-greeter/
├── .claude/             # Claude agent cache and logs
├── .git/                # Git directory
├── docs/                # Project documentation
├── log/                 # Application logs (e.g., app.log)
├── tests/               # Test suite
├── venv/                # Python virtual environment
├── .env                 # Environment variables (API key, schedule)
├── .env.example         # Example for .env
├── .gitignore           # Git ignore file
├── main.py              # FastAPI app, scheduler, and core logic
├── README.md            # This file
├── requirements.txt     # Python dependencies
├── setup.bat            # Windows setup script
├── setup.sh             # Mac/Linux setup script
├── status.bat           # Windows status script
├── status.sh            # Mac/Linux status script
├── stop.bat             # Windows stop script
└── stop.sh              # Mac/Linux stop script
```

## How It Works

### Schedule Logic
The scheduler calculates the next run time based on the `START_TIME` and a fixed 5-hour interval.

-   If you set `START_TIME=09:00`, the job will run at 09:00, 14:00, 19:00, 00:00, 05:00, and so on.
-   If the application is started *after* the day's `START_TIME`, it calculates the next valid 5-hour interval to run. For example, if started at 11:30, the next run will be at 14:00.

### Quiet Hours (Prevent Window)
If `PREVENT_START_TIME` and `PREVENT_END_TIME` are set in `.env`, any job scheduled to run within that time window will be skipped. **Crucially, the schedule will then reset.** The next job will be scheduled for the `START_TIME` on the following day, ensuring the interval sequence always originates from your defined `START_TIME`.
