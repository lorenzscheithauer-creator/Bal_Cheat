# Architect - A Balatro Bot

Architect is a project designed to automate playing the game Balatro. It consists of three main components:

1.  **Python API Server (`server.py`)**: A FastAPI server that acts as a bridge between the game and the user interface. It manages the game state and relays commands.
2.  **Python GUI (`gui.py`)**: A user interface built with CustomTkinter that allows you to control the bot's actions, such as starting, stopping, and setting the risk level.
3.  **Lua Mod (`architect_bridge.lua`, `architect_main.lua`, `dkjson.lua`)**: A set of Lua scripts that run within the Balatro modding environment. These scripts read the game state, send it to the server, and execute commands received from the GUI.

## Installation and Setup

1.  **Install Python Dependencies**:
    ```bash
    pip install fastapi "uvicorn[standard]"
    ```
2.  **Install Lua and LuaSocket**:
    - For Linux (Debian-based):
      ```bash
      sudo apt-get update
      sudo apt-get install -y lua5.1 luarocks
      luarocks install luasocket
      ```
    - For other operating systems, please refer to the official Lua and LuaSocket documentation.

3.  **Place Mod Files**:
    - Copy the `architect` directory and its contents (`server.py`, `gui.py`, `architect_bridge.lua`, `dkjson.lua`, `test_bridge.lua`) into your Balatro mods directory. The exact location will depend on your operating system and Balatro installation.

## How to Use

1.  **Start the Server**:
    - Open a terminal and navigate to the `architect` directory.
    - Run the following command:
      ```bash
      uvicorn server:app --host 127.0.0.1 --port 8000
      ```
    - The server will start and be ready to receive connections.

2.  **Run the GUI**:
    - Open a new terminal.
    - Navigate to the `architect` directory.
    - Run the GUI application:
      ```bash
      python gui.py
      ```
    - A window titled "Architect Controller" will appear. You can use this to start, stop, and control the bot's behavior.

3.  **Run the Lua Mod**:
    - The `architect_main.lua` script is designed to be loaded by a Balatro mod loader. Once the mod is loaded, it will automatically connect to the server and start interacting with it.
    - The `test_bridge.lua` script can be used for testing the connection to the server independently of the game. You can run it from the command line:
      ```bash
      lua5.1 architect/test_bridge.lua
      ```

## Project Structure

- `architect/`:
  - `server.py`: The Python FastAPI server.
  - `gui.py`: The Python GUI application.
  - `architect_bridge.lua`: The Lua module for communication between the game and the server.
  - `dkjson.lua`: A Lua library for JSON encoding and decoding.
  - `test_bridge.lua`: A Lua script for testing the bridge functionality.

## Notes

- This project is a proof-of-concept and may require further development to be fully functional with the Balatro game.
- The `collect_current_game_state()` function in `architect_main.lua` is a placeholder and needs to be implemented to read the actual game state from Balatro.
- The `calculate_synergy_score()` function in `logic.lua` is a simplified example and can be expanded with more complex logic for evaluating joker combinations.
- The `executor.lua` file contains placeholder functions that need to be implemented to interact with the game's internal functions.