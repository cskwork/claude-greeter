#!/usr/bin/env python3
"""
Test script to verify Claude Agent SDK setup
Run this before starting the main server
"""
import os
import sys
import asyncio
from dotenv import load_dotenv

def check_prerequisites():
    """Check all prerequisites are installed"""
    print("=" * 60)
    print("Claude Agent Greeter - Setup Verification")
    print("=" * 60)
    
    errors = []
    
    # Check Python version
    print("\n1. Checking Python version...")
    version = sys.version_info
    if version.major >= 3 and version.minor >= 10:
        print(f"   ✓ Python {version.major}.{version.minor}.{version.micro}")
    else:
        print(f"   ✗ Python {version.major}.{version.minor} (need 3.10+)")
        errors.append("Upgrade Python to 3.10 or higher")
    
    # Check Claude Code CLI
    print("\n2. Checking Claude Code CLI...")
    ret = os.system("claude-code --version > /dev/null 2>&1")
    if ret == 0:
        print("   ✓ Claude Code CLI installed")
    else:
        print("   ✗ Claude Code CLI not found")
        errors.append("Install: npm install -g @anthropic-ai/claude-code")
    
    # Check .env file
    print("\n3. Checking .env file...")
    if os.path.exists(".env"):
        print("   ✓ .env file exists")
        load_dotenv()
        
        api_key = os.getenv("ANTHROPIC_API_KEY")
        start_time = os.getenv("START_TIME")
        
        if api_key and api_key != "your_api_key_here":
            print(f"   ✓ API key configured")
        else:
            print("   ✗ API key not set")
            errors.append("Add your API key to .env file")
        
        if start_time:
            try:
                hour, minute = map(int, start_time.split(":"))
                if 0 <= hour < 24 and 0 <= minute < 60:
                    print(f"   ✓ Start time: {start_time}")
                else:
                    print(f"   ✗ Invalid time: {start_time}")
                    errors.append("Use format HH:MM (00:00 to 23:59)")
            except:
                print(f"   ✗ Invalid time format: {start_time}")
                errors.append("Use format HH:MM (e.g., 09:00)")
        else:
            print("   ! No start time set (will use default 09:00)")
    else:
        print("   ✗ .env file not found")
        errors.append("Create .env file from template")
    
    # Check dependencies
    print("\n4. Checking Python dependencies...")
    try:
        import fastapi
        import uvicorn
        import apscheduler
        import claude_agent_sdk
        import anyio
        print("   ✓ All dependencies installed")
    except ImportError as e:
        print(f"   ✗ Missing dependency: {e.name}")
        errors.append("Run: pip install -r requirements.txt")
    
    # Summary
    print("\n" + "=" * 60)
    if errors:
        print("❌ Setup incomplete. Please fix these issues:")
        for i, error in enumerate(errors, 1):
            print(f"   {i}. {error}")
        print("=" * 60)
        return False
    else:
        print("✅ All checks passed! Ready to run:")
        print("   python main.py")
        print("=" * 60)
        return True


async def test_agent_connection():
    """Test basic connection to Claude Agent SDK"""
    print("\n5. Testing Claude Agent SDK connection...")
    
    try:
        from claude_agent_sdk import query, ClaudeAgentOptions
        
        options = ClaudeAgentOptions(
            max_turns=1,
            allowed_tools=[]
        )
        
        response = ""
        async for message in query(prompt="Say 'test successful' in 3 words or less", options=options):
            if hasattr(message, 'content'):
                for block in message.content:
                    if hasattr(block, 'text'):
                        response += block.text
        
        print(f"   ✓ Connection successful")
        print(f"   Response: {response[:100]}")
        return True
        
    except Exception as e:
        print(f"   ✗ Connection failed: {str(e)}")
        return False


if __name__ == "__main__":
    # Run prerequisite checks
    checks_passed = check_prerequisites()
    
    if checks_passed:
        # Optionally test connection
        print("\nWould you like to test the Claude Agent SDK connection? (y/n)")
        choice = input("> ").lower().strip()
        
        if choice in ['y', 'yes']:
            asyncio.run(test_agent_connection())
    
    sys.exit(0 if checks_passed else 1)
