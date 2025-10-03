-- architect_executor.lua
-- This module contains functions to execute actions in the game.

local M = {}

--[[
    Simulates playing a set of cards.
    @param card_array: A table of card UIDs to play.
]]
function M.play_cards(card_array)
    print("Playing cards: " .. table.concat(card_array, ", "))
    -- In a real implementation, this would call the game's internal function to play cards.
    -- For now, we just print a message.
end

--[[
    Simulates discarding a set of cards.
    @param card_array: A table of card UIDs to discard.
]]
function M.discard_cards(card_array)
    print("Discarding cards: " .. table.concat(card_array, ", "))
    -- In a real implementation, this would call the game's internal function to discard cards.
    -- For now, we just print a message.
end

--[[
    Simulates buying an item from the shop.
    @param item_slot: The index of the item to buy.
]]
function M.buy_from_shop(item_slot)
    print("Buying item from slot: " .. tostring(item_slot))
    -- In a real implementation, this would call the game's internal function to buy an item.
    -- For now, we just print a message.
end

--[[
    Simulates selling a Joker.
    @param joker_slot: The index of the Joker to sell.
]]
function M.sell_joker(joker_slot)
    print("Selling joker from slot: " .. tostring(joker_slot))
    -- In a real implementation, this would call the game's internal function to sell a joker.
    -- For now, we just print a message.
end

--[[
    Simulates rerolling the shop.
]]
function M.reroll_shop()
    print("Rerolling shop...")
    -- In a real implementation, this would call the game's internal function to reroll the shop.
end

return M