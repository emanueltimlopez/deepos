local Economy = {}
Economy.__index = Economy

local MAX_TRANSACTIONS = 50

function Economy.new(initial_credits)
    local self = setmetatable({}, Economy)
    self.credits = initial_credits or 500
    self.transactions = {}
    return self
end

function Economy:getCredits()
    return self.credits
end

function Economy:addCredits(n, description)
    self.credits = self.credits + n
    self:logTransaction(n, description or "Credit")
end

function Economy:spendCredits(n, description)
    if self:canAfford(n) then
        self.credits = self.credits - n
        self:logTransaction(-n, description or "Debit")
        return true
    end
    return false
end

function Economy:canAfford(n)
    return self.credits >= n
end

function Economy:logTransaction(amount, description)
    table.insert(self.transactions, {
        date = os.time(),
        description = description,
        amount = amount,
        balance = self.credits,
    })
    -- Trim to max
    while #self.transactions > MAX_TRANSACTIONS do
        table.remove(self.transactions, 1)
    end
end

function Economy:getTransactions()
    return self.transactions
end

function Economy:serialize()
    -- Keep last 50 transactions
    local txns = {}
    local start = math.max(1, #self.transactions - MAX_TRANSACTIONS + 1)
    for i = start, #self.transactions do
        txns[#txns + 1] = self.transactions[i]
    end
    return {
        credits = self.credits,
        transactions = txns,
    }
end

function Economy:deserialize(data)
    self.credits = data.credits or 500
    self.transactions = data.transactions or {}
end

return Economy
