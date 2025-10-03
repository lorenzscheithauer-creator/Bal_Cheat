-- Architect - Main Control Script
-- This script contains the main loop that drives the bot's behavior.

local G = G or O_O
local a_util = require('architect_utils') -- Placeholder for game utility functions
local bridge = require('architect.architect_bridge')
local logic = require('architect.logic')
local executor = require('architect.executor')

-- Central state table for our mod
local Architect = {
    running = false,
    last_update = 0,
    update_interval = 2, -- seconds
    risk_level = 0.5,
}

-- This function will be called on every frame by the game
function on_update(dt)
    if G.GAME and G.GAME.current_round and G.GAME.current_round.blind_active and not G.GAME.current_round.boss_defeated then
        Architect.last_update = Architect.last_update + dt
        if Architect.last_update > Architect.update_interval then
            Architect.last_update = 0
            main_loop()
        end
    end
end

-- Main logic loop
function main_loop()
    -- 1. Check for commands from the GUI
    local command, err = bridge.get_command()
    if command then
        if command.command == "start" then
            Architect.running = true
            print("Architect: Received START command.")
        elseif command.command == "stop" then
            Architect.running = false
            print("Architect: Received STOP command.")
        elseif command.command == "pause" then
            Architect.running = not Architect.running
            print("Architect: Toggled running state. Now: " .. tostring(Architect.running))
        elseif command.command == "set_risk" then
            Architect.risk_level = command.value
            print("Architect: Updated risk level to " .. tostring(Architect.risk_level))
        end
    end

    -- If not running, do nothing
    if not Architect.running then
        return
    end

    -- 2. Collect the current game state
    local game_state = collect_current_game_state()
    if not game_state then
        print("Architect: Could not get game state.")
        return
    end

    -- 3. Send state to the server
    bridge.send_state(game_state)

    -- 4. Get a decision from the logic module
    local decision = logic.decide_next_action(game_state, Architect.risk_level)

    -- 5. Execute the decision
    if decision and decision.action then
        print("Architect: Executing action - " .. decision.action)
        if decision.action == "play" then
            executor.play_cards(decision.cards)
        elseif decision.action == "discard" then
            executor.discard_cards(decision.cards)
        elseif decision.action == "buy" then
            executor.buy_from_shop(decision.item)
        elseif decision.action == "reroll" then
            executor.reroll_shop()
        elseif decision.action == "end_turn" then
            -- This would likely be a button press in the game's UI
            print("Architect: Ending turn.")
        end
    else
        print("Architect: No action to take.")
    end
end

-- This is a placeholder function. In a real scenario, this would be
-- a complex function that reads data from the game's memory.
function collect_current_game_state()
    -- This function needs to be implemented to read the actual game state
    -- from Balatro's memory or API if available.
    -- For now, we return a mock state for testing purposes.
    return {
      run_info = {
        ante = 1,
        round = 1,
        discards_left = 2,
        hands_left = 4,
        money = 10,
        required_score = 300
      },
      player_cards = {
        hand = {"H_2", "D_3", "S_4", "C_5", "H_A"},
        deck = {},
        discard = {}
      },
      jokers = {
        { name = "Joker", edition = "Normal", value = 4 }
      },
      shop = {
        jokers = {},
        tarot_cards = {},
        planet_cards = {},
        vouchers = {}
      }
    }
end

-- Add the update function to the game's update loop
SMODS.register_hook('update', on_update)

print("Architect Mod Loaded!")