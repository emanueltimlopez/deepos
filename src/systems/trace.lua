local Trace = {}
Trace.__index = Trace

function Trace.new()
    local self = setmetatable({}, Trace)
    self.level = 0.0
    self.raid_triggered = false
    self.close_timer = 0 -- timer for random window closing at 90%+
    self.close_interval = 3 + math.random() * 2 -- 3-5 seconds
    return self
end

function Trace:getLevel()
    return self.level
end

function Trace:update(dt, active_windows, hardware, jackpot_count)
    jackpot_count = jackpot_count or 0

    if active_windows > 0 then
        -- Base rate: 0.1% per second per window (0.001 per window)
        local base_rate = 0.001 * active_windows * hardware:getTraceMultiplier()
        -- Jackpot leads add 0.5% extra per second (0.005 each)
        local jackpot_rate = 0.005 * jackpot_count
        self.level = math.min(1.0, self.level + (base_rate + jackpot_rate) * dt)
    else
        -- Decay when no windows active
        self.level = math.max(0.0, self.level - 0.005 * dt)
    end

    -- Update close timer for 90%+ consequence
    if self.level >= 0.9 and self.level < 1.0 then
        self.close_timer = self.close_timer + dt
    else
        self.close_timer = 0
    end
end

function Trace:shouldCloseWindow()
    if self.close_timer >= self.close_interval then
        self.close_timer = 0
        self.close_interval = 3 + math.random() * 2 -- reset interval
        return true
    end
    return false
end

function Trace:getConsequences()
    if self.level >= 1.0 then
        return "raid"
    elseif self.level >= 0.9 then
        return "close_windows"
    elseif self.level >= 0.7 then
        return "flicker"
    else
        return "none"
    end
end

function Trace:onRaid(economy, hardware)
    local penalty = math.floor(economy:getCredits() * 0.3)
    economy:spendCredits(penalty, "System breach penalty")
    local damaged = hardware:damageRandom()
    self.level = 0.2
    self.raid_triggered = true
    return penalty, damaged
end

function Trace:wasRaidTriggered()
    local v = self.raid_triggered
    self.raid_triggered = false
    return v
end

function Trace:reset()
    self.level = 0.0
end

function Trace:serialize()
    return { level = self.level }
end

function Trace:deserialize(data)
    self.level = data.level or 0.0
end

return Trace
