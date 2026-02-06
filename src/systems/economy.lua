local Economy = {}
Economy.__index = Economy

function Economy.new(initial_credits)
    local self = setmetatable({}, Economy)
    self.credits = initial_credits or 500
    return self
end

function Economy:getCredits()
    return self.credits
end

function Economy:addCredits(n)
    self.credits = self.credits + n
end

function Economy:spendCredits(n)
    if self:canAfford(n) then
        self.credits = self.credits - n
        return true
    end
    return false
end

function Economy:canAfford(n)
    return self.credits >= n
end

function Economy:serialize()
    return { credits = self.credits }
end

function Economy:deserialize(data)
    self.credits = data.credits or 500
end

return Economy
