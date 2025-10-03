-- Test script for architect_bridge.lua

-- In a real mod environment, the path might be different.
-- For testing, we assume the script is run from the repo root.
package.path = package.path .. ';./?.lua'

local bridge = require("architect.architect_bridge")

print("--- Testing Architect Bridge ---")

-- Test 1: Get command when none is set
print("\n[Test 1] Getting command (should be nil)...")
local command, err = bridge.get_command()
if err then
    print("Error:", err)
else
    print("Command received:", command) -- Expected: nil
end

-- Test 2: Send a sample game state
print("\n[Test 2] Sending game state...")
local sample_state = {
    status = "running",
    risk = 0.75,
    game_state = {
        round = 5,
        cash = 120,
        ante = 3
    }
}
local success, err = bridge.send_state(sample_state)
if success then
    print("State sent successfully.")
else
    print("Error sending state:", err)
end

-- To fully test get_command, you would need to:
-- 1. Run the Python server.
-- 2. Run this Lua script to send the initial state.
-- 3. Use curl to POST a command to the server:
--    curl -X POST -H "Content-Type: application/json" -d '{"command": "set_risk", "value": 0.9}' http://127.0.0.1:8000/command
-- 4. Run this Lua script again to fetch the command.

print("\n--- Test sequence complete ---")
print("To test command retrieval, run the server, run this script, send a command with curl, and run this script again.")