local MusicPlayer = {}
MusicPlayer.__index = MusicPlayer

local SUPPORTED_EXTENSIONS = { ".ogg", ".mp3", ".wav" }

function MusicPlayer.new()
    local self = setmetatable({}, MusicPlayer)
    self.playlist = {}
    self.current_index = 0
    self.volume = 0.5
    self.playing = false
    self.source = nil
    self:scanMusic()
    return self
end

function MusicPlayer:scanMusic()
    self.playlist = {}
    local dir = "assets/music"
    local items = love.filesystem.getDirectoryItems(dir)
    for _, file in ipairs(items) do
        for _, ext in ipairs(SUPPORTED_EXTENSIONS) do
            if file:sub(-#ext):lower() == ext:lower() then
                table.insert(self.playlist, {
                    path = dir .. "/" .. file,
                    name = file,
                })
                break
            end
        end
    end
    table.sort(self.playlist, function(a, b) return a.name < b.name end)
    if #self.playlist > 0 and self.current_index == 0 then
        self.current_index = 1
    end
end

function MusicPlayer:getPlaylist()
    return self.playlist
end

function MusicPlayer:getCurrentTrack()
    if self.current_index > 0 and self.current_index <= #self.playlist then
        return self.playlist[self.current_index]
    end
    return nil
end

function MusicPlayer:getTrackCount()
    return #self.playlist
end

function MusicPlayer:isPlaying()
    if self.source and self.source:isPlaying() then
        return true
    end
    return false
end

function MusicPlayer:play()
    if #self.playlist == 0 then return end
    if self.current_index < 1 then self.current_index = 1 end

    -- If already playing this track, do nothing
    if self.source and self.source:isPlaying() then
        return
    end

    self:loadAndPlay()
end

function MusicPlayer:loadAndPlay()
    if self.source then
        self.source:stop()
        self.source = nil
    end

    local track = self:getCurrentTrack()
    if not track then return end

    local ok, src = pcall(love.audio.newSource, track.path, "stream")
    if ok and src then
        self.source = src
        self.source:setVolume(self.volume)
        self.source:play()
        self.playing = true
    end
end

function MusicPlayer:stop()
    if self.source then
        self.source:stop()
    end
    self.playing = false
end

function MusicPlayer:nextTrack()
    if #self.playlist == 0 then return end
    self.current_index = self.current_index + 1
    if self.current_index > #self.playlist then
        self.current_index = 1
    end
    if self.playing then
        self:loadAndPlay()
    end
end

function MusicPlayer:prevTrack()
    if #self.playlist == 0 then return end
    self.current_index = self.current_index - 1
    if self.current_index < 1 then
        self.current_index = #self.playlist
    end
    if self.playing then
        self:loadAndPlay()
    end
end

function MusicPlayer:playTrack(index)
    if index < 1 or index > #self.playlist then return end
    self.current_index = index
    self:loadAndPlay()
end

function MusicPlayer:setVolume(v)
    self.volume = math.max(0, math.min(1, v))
    if self.source then
        self.source:setVolume(self.volume)
    end
end

function MusicPlayer:getVolume()
    return self.volume
end

function MusicPlayer:getProgress()
    if self.source then
        local ok, pos = pcall(self.source.tell, self.source)
        if ok then return pos end
    end
    return 0
end

function MusicPlayer:getDuration()
    if self.source then
        local ok, dur = pcall(self.source.getDuration, self.source)
        if ok and dur then return dur end
    end
    return 0
end

function MusicPlayer:update(dt)
    -- Auto-advance when track finishes
    if self.playing and self.source and not self.source:isPlaying() then
        self:nextTrack()
    end
end

function MusicPlayer:serialize()
    return {
        volume = self.volume,
        current_index = self.current_index,
        playing = self.playing,
    }
end

function MusicPlayer:deserialize(data)
    self.volume = data.volume or 0.5
    self.current_index = data.current_index or (self:getTrackCount() > 0 and 1 or 0)
    if self.current_index > self:getTrackCount() then
        self.current_index = math.max(1, self:getTrackCount())
    end
    -- Resume playback if was playing
    if data.playing and self:getTrackCount() > 0 then
        self:loadAndPlay()
    end
end

return MusicPlayer
