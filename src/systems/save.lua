local json = require("lib.json")

local Save = {}

local SAVE_FILE = "savegame.json"

function Save.save(game_state)
    local data = {
        economy = game_state.economy:serialize(),
        hardware = game_state.hardware:serialize(),
        trace = game_state.trace:serialize(),
        leads = game_state.lead_system:serialize(),
        manual = game_state.manual and game_state.manual:serialize() or nil,
        music_player = game_state.music_player and game_state.music_player:serialize() or nil,
    }
    local encoded = json.encode(data)
    local success, err = love.filesystem.write(SAVE_FILE, encoded)
    return success, err
end

function Save.load()
    if not love.filesystem.getInfo(SAVE_FILE) then
        return nil
    end
    local contents, err = love.filesystem.read(SAVE_FILE)
    if not contents then
        return nil, err
    end
    local ok, data = pcall(json.decode, contents)
    if not ok then
        return nil, "Failed to parse save file"
    end
    return data
end

function Save.exists()
    return love.filesystem.getInfo(SAVE_FILE) ~= nil
end

function Save.delete()
    love.filesystem.remove(SAVE_FILE)
end

return Save
