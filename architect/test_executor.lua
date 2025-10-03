-- Test script for architect_executor.lua

-- In a real mod environment, the path might be different.
-- For testing, we assume the script is run from the repo root.
package.path = package.path .. ';./?.lua'

local executor = require("architect.architect_executor")

print("--- Testing Architect Executor ---")

-- Test play_cards
print("\n[Test] Calling play_cards...")
executor.play_cards({"C_A", "C_K", "C_Q", "C_J", "C_10"})

-- Test discard_cards
print("\n[Test] Calling discard_cards...")
executor.discard_cards({"H_2", "S_3"})

-- Test buy_from_shop
print("\n[Test] Calling buy_from_shop...")
executor.buy_from_shop(1)

-- Test sell_joker
print("\n[Test] Calling sell_joker...")
executor.sell_joker(3)

-- Test reroll_shop
print("\n[Test] Calling reroll_shop...")
executor.reroll_shop()

print("\n--- Executor test complete ---")