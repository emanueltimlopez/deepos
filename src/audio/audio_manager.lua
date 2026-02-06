local AudioManager = {}
AudioManager.__index = AudioManager

function AudioManager.new()
    local self = setmetatable({}, AudioManager)
    self.sounds = {}
    return self
end

function AudioManager:playClick()
    -- placeholder
end

function AudioManager:playAlarm()
    -- placeholder
end

function AudioManager:playAmbience()
    -- placeholder
end

function AudioManager:stopAll()
    -- placeholder
end

return AudioManager
