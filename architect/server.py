from fastapi import FastAPI
from pydantic import BaseModel
import logging
from logging.handlers import RotatingFileHandler
from typing import Optional

# --- Logging Setup ---
# Note: The file-based logging had issues in the environment.
# We keep the code but primarily rely on Uvicorn's console output for verification.
log_formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(name)s - %(message)s')
log_file = 'server.log'
file_handler = RotatingFileHandler(log_file, maxBytes=1024*1024, backupCount=5)
file_handler.setFormatter(log_formatter)
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
logger.addHandler(file_handler)

# --- Pydantic Models ---
class BotState(BaseModel):
    """Represents the full state of the bot, updated by the Lua mod."""
    status: str = "stopped"
    risk: float = 0.5
    game_state: dict = {}

class Command(BaseModel):
    """Represents a command sent from the GUI."""
    command: str
    value: Optional[float] = None

# --- Global State Management ---
# This holds the latest state received from the Lua mod.
bot_state = BotState()
# This holds the last command sent by the GUI, to be picked up by the Lua mod.
last_command: Optional[dict] = None

app = FastAPI()

# --- API Endpoints ---

@app.get("/state", response_model=BotState)
async def get_state():
    """
    (For GUI) Retrieves the current, complete state of the bot as reported by the Lua mod.
    """
    logger.info(f"GUI requested state: {bot_state}")
    return bot_state

@app.post("/state", response_model=BotState)
async def update_state(new_state: BotState):
    """
    (For Lua Mod) Receives a full state update from the game mod and updates the global state.
    """
    global bot_state
    bot_state = new_state
    logger.info(f"Received state update from mod: {new_state}")
    return bot_state

@app.post("/command", response_model=Command)
async def receive_command(command: Command):
    """
    (For GUI) Receives a command from the GUI and stores it to be picked up by the mod.
    """
    global last_command
    last_command = command.dict()
    logger.info(f"GUI sent command: {last_command}")
    return command

@app.get("/command")
async def get_command():
    """
    (For Lua Mod) Allows the game mod to poll for the latest command from the GUI.
    Clears the command after retrieval to ensure it's processed only once.
    """
    global last_command
    if last_command:
        command_to_send = last_command
        last_command = None  # Clear command after sending
        logger.info(f"Sending command to mod: {command_to_send}")
        return command_to_send
    return {}

@app.get("/")
async def root():
    """Root endpoint to confirm the server is running."""
    return {"message": "Architect API server is running."}