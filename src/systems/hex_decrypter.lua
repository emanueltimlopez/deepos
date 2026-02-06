local Theme = require("src.ui.theme")

local HexDecrypter = {}
HexDecrypter.__index = HexDecrypter

local HEX_CHARS = "0123456789ABCDEF"
local COLS = 16

function HexDecrypter.new(lead)
    local self = setmetatable({}, HexDecrypter)
    self.lead = lead
    self.progress = 0.0
    self.buffer = {}
    self.complete = false
    self.aborted = false
    self.started = false

    -- Virus state
    self.virus_revealed = false
    self.virus_executed = false
    self.virus_reveal_threshold = 0.25 + math.random() * 0.10 -- 25-35%
    self.virus_execute_threshold = 0.60

    -- Initialize buffer with the lead's raw hex data (static preview)
    for i = 1, lead.data_size do
        self.buffer[i] = lead.hex_data[i]
    end

    return self
end

function HexDecrypter:start()
    self.started = true
    -- Scramble buffer to noise now that decryption begins
    for i = 1, self.lead.data_size do
        local idx = math.random(16)
        self.buffer[i] = HEX_CHARS:sub(idx, idx)
    end
end

function HexDecrypter:isStarted()
    return self.started
end

function HexDecrypter:update(dt, gpu_speed)
    if not self.started then return end
    if self.complete or self.aborted or self.virus_executed then return end

    local rate = 0.08 * gpu_speed / self.lead.security_level
    self.progress = math.min(1.0, self.progress + rate * dt)

    -- Check virus reveal
    if self.lead.is_virus and not self.virus_revealed and self.progress >= self.virus_reveal_threshold then
        self.virus_revealed = true
        self:injectVirusPattern()
    end

    -- Check virus execution (past 60% without abort)
    if self.lead.is_virus and self.progress >= self.virus_execute_threshold and not self.aborted then
        self.virus_executed = true
        return -- caller handles crash
    end

    -- Update buffer based on progress phase
    for i = 1, self.lead.data_size do
        local reveal_threshold = (i / self.lead.data_size)

        if self.progress >= reveal_threshold then
            -- Reveal real data
            self.buffer[i] = self.lead.hex_data[i]
        elseif self.progress > reveal_threshold * 0.4 then
            -- Partial: flicker between noise and real
            if math.random() < self.progress then
                self.buffer[i] = self.lead.hex_data[i]
            else
                local idx = math.random(16)
                self.buffer[i] = HEX_CHARS:sub(idx, idx)
            end
        else
            -- Pure noise
            local idx = math.random(16)
            self.buffer[i] = HEX_CHARS:sub(idx, idx)
        end
    end

    if self.progress >= 1.0 then
        self.complete = true
    end
end

function HexDecrypter:injectVirusPattern()
    if not self.lead.virus_pattern then return end

    -- Inject the virus pattern string into the buffer at a visible position
    local pattern = self.lead.virus_pattern
    local start_pos = math.max(1, math.floor(self.lead.data_size * 0.2))

    for i = 1, #pattern do
        local char = pattern:sub(i, i)
        local buf_idx = start_pos + i - 1
        if buf_idx <= self.lead.data_size then
            -- Convert char to hex representation
            local hex = string.format("%X", string.byte(char))
            self.buffer[buf_idx] = hex:sub(1, 1)
        end
    end
end

function HexDecrypter:abort()
    self.aborted = true
end

function HexDecrypter:isComplete()
    return self.complete
end

function HexDecrypter:isAborted()
    return self.aborted
end

function HexDecrypter:isVirusRevealed()
    return self.virus_revealed
end

function HexDecrypter:isVirusExecuted()
    return self.virus_executed
end

function HexDecrypter:getProgress()
    return self.progress
end

function HexDecrypter:draw(x, y, w, h)
    local font = love.graphics.getFont()
    local char_w = font:getWidth("F") + 2
    local line_h = font:getHeight() + 2
    local padding = 8

    -- Header
    love.graphics.setColor(Theme.colors.text)
    if self.started then
        love.graphics.print(string.format("Decrypting: %s [%s]", self.lead.real_data, self.lead.rarity:upper()),
            x + padding, y + padding)
    else
        local cost = self.lead.open_cost or 15
        love.graphics.print(string.format("Lead #%d  [Sec:%d]  Cost: %d CR",
            self.lead.id, self.lead.security_level, cost),
            x + padding, y + padding)
    end

    -- Virus warning
    if self.virus_revealed and not self.virus_executed then
        love.graphics.setColor(0.8, 0.0, 0.0, 1.0)
        love.graphics.print("!! VIRUS DETECTED: " .. (self.lead.virus_pattern or "UNKNOWN") .. " - ABORT NOW !!",
            x + padding, y + padding + line_h)
    end

    -- Progress bar (only when decrypting)
    local bar_y = y + padding + line_h * 2 + 4
    local bar_w = w - padding * 2
    local bar_h = 14

    if self.started then
        -- White background for bar
        love.graphics.setColor(Theme.colors.progress_bg)
        love.graphics.rectangle("fill", x + padding, bar_y, bar_w, bar_h)

        -- Inset border
        Theme.drawInsetRect(x + padding, bar_y, bar_w, bar_h)

        -- Fill color: red if virus revealed, blue otherwise
        if self.virus_revealed then
            love.graphics.setColor(0.8, 0.1, 0.1, 1.0)
        else
            love.graphics.setColor(Theme.colors.progress_fill)
        end
        love.graphics.rectangle("fill", x + padding + 1, bar_y + 1, (bar_w - 2) * self.progress, bar_h - 2)

        -- Percentage text
        love.graphics.setColor(Theme.colors.text)
        love.graphics.print(string.format("%.0f%%", self.progress * 100), x + w - 50, bar_y)
    else
        -- Preview mode label
        love.graphics.setColor(Theme.colors.text_disabled)
        love.graphics.print("-- PREVIEW -- inspect hex data before processing", x + padding, bar_y)
    end

    -- Hex grid
    local grid_y = bar_y + 22
    local display_count = math.min(self.lead.data_size, 256) -- limit display

    for i = 1, display_count do
        local col = ((i - 1) % COLS)
        local row = math.floor((i - 1) / COLS)
        local cx = x + padding + col * (char_w + 4)
        local cy = grid_y + row * line_h

        if cy > y + h - line_h then break end

        if not self.started then
            -- Preview: all chars visible, static
            love.graphics.setColor(0.0, 0.0, 0.0, 1.0)
        else
            -- Color based on reveal state
            local revealed = self.progress >= (i / self.lead.data_size)

            -- Highlight virus pattern chars in red
            if self.virus_revealed and self.lead.virus_pattern then
                local pattern_start = math.max(1, math.floor(self.lead.data_size * 0.2))
                local pattern_end = pattern_start + #self.lead.virus_pattern - 1
                if i >= pattern_start and i <= pattern_end then
                    love.graphics.setColor(0.9, 0.0, 0.0, 1.0)
                    love.graphics.print(self.buffer[i] or ".", cx, cy)
                    goto continue
                end
            end

            if revealed then
                love.graphics.setColor(0.0, 0.0, 0.0, 1.0)
            elseif self.progress > (i / self.lead.data_size) * 0.4 then
                love.graphics.setColor(0.4, 0.4, 0.4, 0.8)
            else
                love.graphics.setColor(0.7, 0.7, 0.7, 0.5)
            end
        end

        love.graphics.print(self.buffer[i] or ".", cx, cy)
        ::continue::
    end

    -- ASCII sidebar
    local ascii_x = x + padding + COLS * (char_w + 4) + 10
    for row = 0, math.floor(display_count / COLS) - 1 do
        local cy = grid_y + row * line_h
        if cy > y + h - line_h then break end

        local str = ""
        for col = 0, COLS - 1 do
            local idx = row * COLS + col + 1
            if idx <= display_count then
                local b = self.buffer[idx]
                local n = tonumber(b, 16)
                if n and n >= 32 and n < 127 then
                    str = str .. string.char(n)
                else
                    str = str .. "."
                end
            end
        end
        love.graphics.setColor(0.5, 0.5, 0.5, 0.6)
        love.graphics.print(str, ascii_x, cy)
    end
end

return HexDecrypter
