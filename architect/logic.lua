-- architect/logic.lua
-- This file contains the core decision-making logic for the bot.

local M = {}

-- Placeholder for Joker data. This would be populated with actual game data.
local JOKER_DATA = {
    ["Joker"] = { tags = {"additive_mult"} },
    ["Joker (Foil)"] = { tags = {"additive_mult", "foil"} },
    -- ... more jokers
}

--- Calculates a synergy score for a given set of jokers.
-- @param jokers A table of joker objects.
-- @return A numerical score representing the synergy of the jokers.
function M.calculate_synergy_score(jokers)
    -- This is a simplified example. A real implementation would have more complex logic.
    local score = 0
    local mult_count = 0
    local x_mult_count = 0

    for _, joker in ipairs(jokers) do
        if joker.tags then
            for _, tag in ipairs(joker.tags) do
                if tag == "additive_mult" then
                    score = score + 1
                    mult_count = mult_count + 1
                elseif tag == "mult_multiplicative" then
                    score = score + 5
                    x_mult_count = x_mult_count + 1
                elseif tag == "economy" then
                    score = score + 2
                end
            end
        end
    end

    -- Bonus for having a mix of multiplier types
    if mult_count > 0 and x_mult_count > 0 then
        score = score * 1.5
    end

    return score
end

--- Placeholder for evaluating all possible hands.
-- @param hand A table of cards.
-- @return A table representing the best hand found.
function M.evaluate_all_possible_hands(hand)
    -- In a real implementation, this would involve complex poker hand evaluation.
    -- For now, we'll just return a placeholder.
    print("Evaluating all possible hands...")
    return {
        hand_type = "Full House",
        cards = hand,
        score = 1000 -- A dummy score
    }
end

--- Placeholder for deciding which hand to play.
-- @param state The current game state.
-- @param risk The current risk level.
-- @return A table representing the action to take.
function M.decide_next_action(state, risk)
    -- 1. Shop-Phase oder Spiel-Phase?
    if state.run_info.hands_left > 0 and state.run_info.blinds[1].active then -- Assuming blinds[1] is the current blind
        -- HAND-LOGIK
        local mode = 'Farming'
        if state.run_info.lives == 1 then
            mode = 'PvP'
        end
        print("Current mode: " .. mode)

        local best_hand = M.evaluate_all_possible_hands(state.player_cards.hand)

        -- Simplified logic: if the hand is good enough, play it. Otherwise, discard.
        if best_hand.score > (state.run_info.required_score / state.run_info.hands_left) * risk then
            print("Decided to play hand: " .. table.concat(best_hand.cards, ", "))
            return { action = "play", cards = best_hand.cards }
        else
            -- Placeholder for discard logic
            print("Decided to discard.")
            -- In a real implementation, this would select specific cards to discard
            return { action = "discard", cards = {state.player_cards.hand[1]} }
        end
    else
        -- SHOP-LOGIK
        print("In shop phase.")
        -- Placeholder for shop logic
        local interest_cap = 25
        if state.run_info.money > interest_cap then
            -- Placeholder for buying logic
            print("Decided to buy first available card.")
            if state.shop.jokers and #state.shop.jokers > 0 then
                return { action = "buy", item = state.shop.jokers[1].name }
            elseif state.shop.tarot_cards and #state.shop.tarot_cards > 0 then
                return { action = "buy", item = state.shop.tarot_cards[1].name }
            elseif state.shop.planet_cards and #state.shop.planet_cards > 0 then
                return { action = "buy", item = state.shop.planet_cards[1].name }
            elseif state.shop.vouchers and #state.shop.vouchers > 0 then
                return { action = "buy", item = state.shop.vouchers[1].name }
            end
        end
        print("No action in shop.")
        return { action = "end_turn" }
    end
end

return M