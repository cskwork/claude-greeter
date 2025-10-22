import os
import asyncio
import traceback
from datetime import datetime, time
from contextlib import asynccontextmanager

import anyio
from fastapi import FastAPI, HTTPException
from dotenv import load_dotenv
from apscheduler.schedulers.asyncio import AsyncIOScheduler
from apscheduler.triggers.interval import IntervalTrigger
from claude_agent_sdk import query, ClaudeAgentOptions

# Load environment variables
load_dotenv()

# Configuration
START_TIME = os.getenv("START_TIME", "09:00")
TIMEZONE = os.getenv("TIMEZONE", None)
LOG_DIR = "log"

# Create log directory if it doesn't exist
if not os.path.exists(LOG_DIR):
    os.makedirs(LOG_DIR)

# Scheduler instance
scheduler = AsyncIOScheduler(timezone=TIMEZONE)


async def greet_agent():
    """Send 'hi' message to Claude agent and log response"""
    log_file_path = os.path.join(LOG_DIR, f"{datetime.now().strftime('%Y-%m-%d')}.log")

    try:
        print(f"[{datetime.now()}] Greeting Claude agent...")
        
        options = ClaudeAgentOptions(
            system_prompt="You are a friendly assistant. Keep responses brief.",
            max_turns=1,
            allowed_tools=[]  # No tools needed for simple greeting
        )
        
        full_response = ""
        async for message in query(prompt="Hi!", options=options):
            # Extract text from message
            if hasattr(message, 'content'):
                for block in message.content:
                    if hasattr(block, 'text'):
                        full_response += block.text
        
        log_message = f"[{datetime.now()}] Claude responded: {full_response}\n"
        print(log_message.strip())
        
        with open(log_file_path, "a", encoding="utf-8") as f:
            f.write(log_message)

        return {"status": "success", "response": full_response}
        
    except Exception as e:
        error_msg = f"Error greeting agent: {str(e)}"
        log_message = f"[{datetime.now()}] {error_msg}\n{traceback.format_exc()}\n"
        print(f"[{datetime.now()}] {error_msg}")
        traceback.print_exc()

        with open(log_file_path, "a", encoding="utf-8") as f:
            f.write(log_message)

        return {"status": "error", "message": error_msg}


def calculate_next_run_time():
    """Calculate the next scheduled run time based on START_TIME"""
    try:
        hour, minute = map(int, START_TIME.split(":"))
        now = datetime.now()
        start_time = now.replace(hour=hour, minute=minute, second=0, microsecond=0)
        
        # If start time has passed today, schedule for next occurrence
        if now > start_time:
            # Find next 5-hour interval from start time
            hours_since_start = (now - start_time).total_seconds() / 3600
            intervals_passed = int(hours_since_start / 5) + 1
            next_run = start_time.replace(hour=(hour + (intervals_passed * 5)) % 24)
            
            # Adjust date if we wrapped around midnight
            if next_run <= now:
                from datetime import timedelta
                next_run = start_time + timedelta(hours=(intervals_passed + 1) * 5)
        else:
            next_run = start_time
        
        return next_run
        
    except ValueError:
        raise ValueError(f"Invalid START_TIME format: {START_TIME}. Use HH:MM (24-hour format)")


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Manage scheduler lifecycle"""
    try:
        # Calculate first run time
        next_run = calculate_next_run_time()
        print(f"Scheduling first greeting at: {next_run}")
        
        # Schedule task to run every 5 hours starting from calculated time
        scheduler.add_job(
            greet_agent,
            trigger=IntervalTrigger(hours=5, start_date=next_run),
            id="greet_agent_job",
            name="Greet Claude Agent",
            replace_existing=True
        )
        
        scheduler.start()
        print(f"Scheduler started. Next run: {scheduler.get_job('greet_agent_job').next_run_time}")
        
        yield
        
    finally:
        scheduler.shutdown()
        print("Scheduler stopped")


# Initialize FastAPI with lifespan
app = FastAPI(
    title="Claude Agent Greeter",
    description="Scheduled API that greets Claude agent every 5 hours",
    lifespan=lifespan
)


@app.get("/")
async def root():
    """Health check endpoint"""
    next_run = scheduler.get_job('greet_agent_job')
    return {
        "status": "running",
        "message": "Claude Agent Greeter is active",
        "next_scheduled_run": str(next_run.next_run_time) if next_run else "Not scheduled",
        "interval": "Every 5 hours",
        "start_time": START_TIME
    }


@app.post("/greet")
async def manual_greet():
    """Manually trigger a greeting (doesn't affect schedule)"""
    result = await greet_agent()
    return result


@app.get("/schedule")
async def get_schedule():
    """Get current schedule information"""
    job = scheduler.get_job('greet_agent_job')
    if not job:
        raise HTTPException(status_code=404, detail="Schedule not found")
    
    return {
        "job_id": job.id,
        "job_name": job.name,
        "next_run_time": str(job.next_run_time),
        "trigger": str(job.trigger),
        "interval_hours": 5,
        "start_time_config": START_TIME
    }


if __name__ == "__main__":
    import uvicorn
    
    print("=" * 60)
    print("Claude Agent Greeter API")
    print("=" * 60)
    print(f"Start time: {START_TIME}")
    print(f"Interval: Every 5 hours")
    print(f"Timezone: {TIMEZONE or 'System default'}")
    print("=" * 60)
    
    uvicorn.run(app, host="0.0.0.0", port=8000)
