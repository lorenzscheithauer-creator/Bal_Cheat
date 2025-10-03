-- Architect Bridge: Handles communication between the Lua mod and the Python server.
-- It requires 'dkjson.lua' and 'socket.http' to be available in the search path.

local http = require("socket.http")
local json = require("architect.dkjson") -- Assuming dkjson.lua is in the 'architect' directory

local M = {}

local API_URL = "http://127.0.0.1:8000"

-- Function to send the game state to the server
function M.send_state(state_table)
    if not state_table or type(state_table) ~= "table" then
        return false, "Invalid state_table: not a table."
    end

    local success, data = pcall(json.encode, state_table)
    if not success then
        return false, "Failed to encode state to JSON: " .. tostring(data)
    end

    local response_body = {}
    local res, code, headers, status = http.request{
        url = API_URL .. "/state",
        method = "POST",
        headers = {
            ["Content-Type"] = "application/json",
            ["Content-Length"] = #data
        },
        source = ltn12.source.string(data),
        sink = ltn12.sink.table(response_body)
    }

    if not res then
        return false, "HTTP request failed: " .. tostring(code)
    end

    if code ~= 200 then
        return false, "Server returned error: " .. status
    end

    return true, table.concat(response_body)
end

-- Function to get a command from the server
function M.get_command()
    local response_body = {}
    local res, code, headers, status = http.request{
        url = API_URL .. "/command",
        sink = ltn12.sink.table(response_body)
    }

    if not res then
        return nil, "HTTP request failed: " .. tostring(code)
    end

    if code ~= 200 then
        return nil, "Server returned error: " .. status
    end

    local body_str = table.concat(response_body)
    if body_str == "{}" then
        return nil, "No command available."
    end

    local success, command_table = pcall(json.decode, body_str)
    if not success then
        return nil, "Failed to decode command JSON: " .. tostring(command_table)
    end

    return command_table
end

return M
