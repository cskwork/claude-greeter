# GEMINI Project Context: Claude Greeter API

## Project Overview

This project is a Python-based scheduled API service designed to interact with the Anthropic Claude agent. Its primary function is to send a "Hi!" message to the Claude agent every 5 hours. The application is built using FastAPI for the web framework and APScheduler for task scheduling. It is designed to be robust, with features like retry logic with exponential backoff for API calls, a "prevent window" to avoid execution during specified quiet hours, and background execution capabilities.

## Core Technologies

*   **Programming Language:** Python
*   **Web Framework:** FastAPI
*   **Web Server:** Uvicorn
*   **Task Scheduling:** APScheduler
*   **Claude Interaction:** `claude-agent-sdk`
*   **Configuration:** `python-dotenv` for managing environment variables from a `.env` file.
*   **Concurrency:** `anyio` and `asyncio` for asynchronous operations.

## Key Files

*   **`main.py`**: The main entry point of the application. It contains the FastAPI application, the APScheduler setup, the logic for greeting the Claude agent, and the API endpoints.
*   **`requirements.txt`**: Lists all the Python dependencies required for the project.
*   **`.env.example`**: An example file for the environment variables. Users are expected to copy this to `.env` and fill in their details.
*   **`setup.sh` / `setup.bat`**: Shell and batch scripts for setting up the project. They handle creating a virtual environment, installing dependencies, and starting the application in the background.
*   **`stop.sh` / `stop.bat`**: Scripts to stop the background application.
*   **`status.sh` / `status.bat`**: Scripts to check the status of the background application.
*   **`README.md`**: Contains detailed instructions on how to set up and use the project.

## Setup and Execution

The project is intended to be set up and run using the provided shell scripts.

1.  **Setup:**
    *   Run `./setup.sh` (on Mac/Linux) or `setup.bat` (on Windows).
    *   This will:
        *   Create a Python virtual environment (`venv`).
        *   Install the required dependencies from `requirements.txt`.
        *   Create a `.env` file from `.env.example` if it doesn't exist.
        *   Start the application in the background.

2.  **Running the Application:**
    *   The `setup` script starts the application automatically.
    *   To run it manually for development, use: `python main.py`.

3.  **Stopping the Application:**
    *   Run `./stop.sh` or `stop.bat`.

4.  **Checking the Status:**
    *   Run `./status.sh` or `status.bat`.

## API Endpoints

The application exposes the following REST API endpoints:

*   **`GET /`**: A health check endpoint that returns the status of the application, the next scheduled run time, and other configuration details.
*   **`POST /greet`**: Manually triggers the greeting process to the Claude agent. This does not affect the regular schedule.
*   **`GET /schedule`**: Provides detailed information about the current job schedule.

## Configuration

The application is configured via a `.env` file in the project root. The following variables are used:

*   **`ANTHROPIC_API_KEY`**: Your Anthropic API key. **(Required)**
*   **`START_TIME`**: The time of day (in HH:MM format) to start the 5-hour interval schedule. **(Required)**
*   **`TIMEZONE`**: The timezone for the scheduler (e.g., `America/New_York`). Defaults to the system timezone if not set.
*   **`PREVENT_START_TIME`**: The start time of the "prevent window" (in HH:MM format) during which the job will not run.
*   **`PREVENT_END_TIME`**: The end time of the "prevent window".

## Development Conventions

*   **Asynchronous Code:** The application heavily uses `asyncio` and `async/await` syntax, which is idiomatic for FastAPI.
*   **Error Handling:** The `greet_agent` function includes a `try...except` block to catch and log any exceptions that occur during the interaction with the Claude agent. It also features a retry mechanism with exponential backoff.
*   **Modularity:** The code is well-structured, with clear separation of concerns (e.g., scheduler setup, API endpoints, agent interaction logic).
*   **Logging:** The application logs its activities to the console and to log files in the `log/` directory.
*   **Comments:** The code is commented in Korean.
