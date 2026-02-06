local Hardware = {}
Hardware.__index = Hardware

local COMPONENTS = {
    ram  = { base_cost = 200,  label = "RAM" },
    gpu  = { base_cost = 300,  label = "GPU" },
    ssd  = { base_cost = 150,  label = "SSD" },
    cpu  = { base_cost = 250,  label = "CPU" },
}

local SOFTWARE = {
    manual_v2      = { cost = 500,  label = "Manual v2",      description = "Advanced patterns" },
    manual_v3      = { cost = 1500, label = "Manual v3",      description = "Expert signatures" },
    threat_scanner = { cost = 300,  label = "Threat Scanner",  description = "Inbox danger indicator" },
    value_estimator = { cost = 800, label = "Value Estimator", description = "Inbox credit range" },
    ocr_scanner    = { cost = 3000, label = "OCR Scanner",     description = "Auto-highlight patterns" },
}

function Hardware.new()
    local self = setmetatable({}, Hardware)
    self.levels = {
        ram = 0,
        gpu = 0,
        ssd = 0,
        cpu = 0,
    }
    self.software = {
        manual_v2 = false,
        manual_v3 = false,
        threat_scanner = false,
        value_estimator = false,
        ocr_scanner = false,
    }
    return self
end

function Hardware:getLevel(component)
    return self.levels[component] or 0
end

function Hardware:getMaxWindows()
    return 2 + self.levels.ram
end

function Hardware:getDecryptSpeed()
    return 1.0 + self.levels.gpu * 0.5
end

function Hardware:getMaxLeads()
    return 3 + self.levels.ssd * 2
end

function Hardware:getTraceMultiplier()
    return math.max(0.3, 1.0 - self.levels.cpu * 0.15)
end

function Hardware:getUpgradeCost(component)
    local info = COMPONENTS[component]
    if not info then return 9999 end
    return math.floor(info.base_cost * math.pow(2, self.levels[component]))
end

function Hardware:upgrade(component, economy)
    local cost = self:getUpgradeCost(component)
    if economy:canAfford(cost) then
        economy:spendCredits(cost)
        self.levels[component] = self.levels[component] + 1
        return true
    end
    return false
end

function Hardware:hasSoftware(name)
    return self.software[name] == true
end

function Hardware:buySoftware(name, economy)
    local info = SOFTWARE[name]
    if not info then return false end
    if self.software[name] then return false end -- already owned
    if not economy:canAfford(info.cost) then return false end
    economy:spendCredits(info.cost)
    self.software[name] = true
    return true
end

function Hardware:getSoftwareList()
    local list = {}
    for name, info in pairs(SOFTWARE) do
        table.insert(list, {
            name = name,
            label = info.label,
            description = info.description,
            cost = info.cost,
            owned = self.software[name] == true,
        })
    end
    table.sort(list, function(a, b) return a.cost < b.cost end)
    return list
end

function Hardware:damageRandom()
    local components = {"ram", "gpu", "ssd", "cpu"}
    local comp = components[math.random(#components)]
    if self.levels[comp] > 0 then
        self.levels[comp] = self.levels[comp] - 1
        return comp
    end
    return nil
end

function Hardware:getComponentList()
    local list = {}
    for name, info in pairs(COMPONENTS) do
        table.insert(list, {
            name = name,
            label = info.label,
            level = self.levels[name],
            cost = self:getUpgradeCost(name),
        })
    end
    table.sort(list, function(a, b) return a.name < b.name end)
    return list
end

function Hardware:serialize()
    return {
        levels = self.levels,
        software = self.software,
    }
end

function Hardware:deserialize(data)
    self.levels = data.levels or { ram=0, gpu=0, ssd=0, cpu=0 }
    local default_sw = { manual_v2=false, manual_v3=false, threat_scanner=false, value_estimator=false, ocr_scanner=false }
    if data.software then
        for k, v in pairs(data.software) do default_sw[k] = v end
    end
    self.software = default_sw
end

return Hardware
