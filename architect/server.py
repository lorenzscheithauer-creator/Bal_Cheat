from fastapi import FastAPI
from pydantic import BaseModel
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class BotState(BaseModel):
    """
    Represents the state of the bot.
    """
    status: str = "stopped"
    risk: float = 0.5
    game_state: dict = {}

# Create a global state object
bot_state = BotState()

app = FastAPI()

@app.get("/state", response_model=BotState)
async def get_state():
    """
    Retrieves the current state of the bot.
    """
    logger.info("Current state requested.")
    return bot_state

@app.post("/start", response_model=BotState)
async def start_bot():
    """
    Sets the bot's status to 'running'.
    """
    logger.info("Received start command.")
    bot_state.status = "running"
    return bot_state

@app.post("/stop", response_model=BotState)
async def stop_bot():
    """
    Sets the bot's status to 'stopped'.
    """
    logger.info("Received stop command.")
    bot_state.status = "stopped"
    return bot_state

@app.post("/risk", response_model=BotState)
async def set_risk(risk_update: dict):
    """
    Updates the bot's risk level.
    Expects a JSON with a "risk" key.
    """
    new_risk = risk_update.get("risk")
    if new_risk is not None and isinstance(new_risk, (float, int)):
        logger.info(f"Updating risk to {new_risk}")
        bot_state.risk = float(new_risk)
    else:
        logger.warning(f"Invalid risk value provided: {new_risk}")
    return bot_state

@app.post("/game_state", response_model=BotState)
async def update_game_state(new_game_state: dict):
    """
    Updates the game state data from the Lua mod.
    """
    logger.info(f"Received game state update: {new_game_state}")
    bot_state.game_state = new_game_state
    return bot_state

@app.get("/")
async def root():
    """
    Root endpoint to confirm the server is running.
    """
    return {"message": "Architect API server is running."}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)