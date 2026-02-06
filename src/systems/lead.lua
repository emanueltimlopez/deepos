local Lead = {}
Lead.__index = Lead

local next_id = 1

local RARITY_TABLE = {
    { rarity = "basura",   weight = 60, reward_min = 20,   reward_max = 80,   data_size = 64,  security = 1 },
    { rarity = "standard", weight = 30, reward_min = 100,  reward_max = 300,  data_size = 128, security = 2 },
    { rarity = "rare",     weight = 8,  reward_min = 400,  reward_max = 800,  data_size = 256, security = 3 },
    { rarity = "jackpot",  weight = 2,  reward_min = 1000, reward_max = 3000, data_size = 512, security = 4 },
}

local HEX_CHARS = "0123456789ABCDEF"

local VIRUS_PATTERNS = { "TROJAN.V3", "WORM.X1", "ROOTKIT", "MALWARE.Z", "SPYWARE.Q" }

-- Virus chance per rarity
local VIRUS_CHANCE = {
    basura = 0.10,
    standard = 0.05,
    rare = 0,
    jackpot = 0,
}

function Lead.new()
    local self = setmetatable({}, Lead)
    self.available_leads = {}
    self.max_leads = 3
    self.spawn_timer = 0
    self.spawn_interval = 5.0
    return self
end

function Lead:setMaxLeads(n)
    self.max_leads = n
end

function Lead:getAvailableLeads()
    return self.available_leads
end

function Lead:removeLead(id)
    for i, lead in ipairs(self.available_leads) do
        if lead.id == id then
            table.remove(self.available_leads, i)
            return lead
        end
    end
    return nil
end

function Lead:trashLead(id)
    return self:removeLead(id)
end

function Lead:update(dt)
    self.spawn_timer = self.spawn_timer + dt
    if self.spawn_timer >= self.spawn_interval and #self.available_leads < self.max_leads then
        self.spawn_timer = 0
        local lead = self:generateLead()
        table.insert(self.available_leads, lead)
        return lead -- signal new lead
    end
    return nil
end

function Lead:generateLead()
    -- Roll rarity
    local roll = math.random(100)
    local cumulative = 0
    local rarity_info = RARITY_TABLE[1]
    for _, entry in ipairs(RARITY_TABLE) do
        cumulative = cumulative + entry.weight
        if roll <= cumulative then
            rarity_info = entry
            break
        end
    end

    -- Determine virus
    local is_virus = false
    local virus_pattern = nil
    local virus_chance = VIRUS_CHANCE[rarity_info.rarity] or 0
    if virus_chance > 0 and math.random() < virus_chance then
        is_virus = true
        virus_pattern = VIRUS_PATTERNS[math.random(#VIRUS_PATTERNS)]
    end

    -- 80/20 snapshot fidelity: 80% snapshot matches real value, 20% mismatch
    local snapshot_fidelity = math.random() < 0.80

    local hex_data = self:generateHexData(rarity_info.data_size, rarity_info.rarity)

    -- If low fidelity, swap the visual appearance
    local display_rarity = rarity_info.rarity
    if not snapshot_fidelity then
        -- Good lead looks bad, or bad lead looks good
        if rarity_info.rarity == "basura" or rarity_info.rarity == "standard" then
            -- Make it look better than it is
            display_rarity = math.random() < 0.5 and "rare" or "standard"
        else
            -- Make it look worse than it is
            display_rarity = math.random() < 0.5 and "basura" or "standard"
        end
        hex_data = self:generateHexData(rarity_info.data_size, display_rarity)
    end

    -- Generate hex preview (first 16 chars for inbox snapshot)
    local hex_preview = ""
    for i = 1, math.min(16, #hex_data) do
        hex_preview = hex_preview .. hex_data[i]
        if i % 2 == 0 and i < 16 then
            hex_preview = hex_preview .. " "
        end
    end

    local lead = {
        id = next_id,
        rarity = rarity_info.rarity,
        display_rarity = display_rarity,
        reward_min = rarity_info.reward_min,
        reward_max = rarity_info.reward_max,
        security_level = rarity_info.security,
        hex_data = hex_data,
        real_data = self:generateRealData(rarity_info.rarity),
        data_size = rarity_info.data_size,
        is_virus = is_virus,
        virus_pattern = virus_pattern,
        snapshot_fidelity = snapshot_fidelity,
        hex_preview = hex_preview,
    }
    next_id = next_id + 1
    return lead
end

function Lead:generateHexData(size, rarity)
    local data = {}

    if rarity == "basura" then
        -- Repetitive blocks, dead sectors: lots of 00 and FF
        local patterns = {"0", "0", "F", "F", "0", "0", "F", "F", "0", "0"}
        for i = 1, size do
            if math.random() < 0.6 then
                -- Repetitive pattern
                data[i] = patterns[((i - 1) % #patterns) + 1]
            else
                local idx = math.random(#HEX_CHARS)
                data[i] = HEX_CHARS:sub(idx, idx)
            end
        end
    elseif rarity == "standard" then
        -- Mix of ASCII-legible ranges (4-7) and some junk
        for i = 1, size do
            if math.random() < 0.4 then
                -- ASCII printable range hex digits (4,5,6,7 = 40-7F)
                local ascii_hex = {"4","5","6","7"}
                data[i] = ascii_hex[math.random(#ascii_hex)]
            elseif math.random() < 0.3 then
                -- Some dead bytes
                data[i] = math.random() < 0.5 and "0" or "F"
            else
                local idx = math.random(#HEX_CHARS)
                data[i] = HEX_CHARS:sub(idx, idx)
            end
        end
    elseif rarity == "rare" then
        -- Dense and varied, few gaps (no 00/FF runs)
        for i = 1, size do
            -- Avoid 0 and F to look dense
            local idx = math.random(2, 15) -- skip 0 and F
            data[i] = HEX_CHARS:sub(idx, idx)
        end
    elseif rarity == "jackpot" then
        -- Complex structures, very dense, structured blocks
        local structures = {"A","B","C","D","E","8","9","3","7"}
        for i = 1, size do
            if i % 16 < 2 then
                -- Header markers
                data[i] = "E"
            else
                data[i] = structures[math.random(#structures)]
            end
        end
    else
        -- Fallback: random
        for i = 1, size do
            local idx = math.random(#HEX_CHARS)
            data[i] = HEX_CHARS:sub(idx, idx)
        end
    end

    return data
end

function Lead:generateRealData(rarity)
    local snippets = {
        basura = {
            "EMPTY_PACKET", "NULL_SIGNAL", "JUNK_DATA", "CORRUPTED",
            "NO_VALUE", "DEAD_END", "GARBAGE_0x0",
        },
        standard = {
            "ACCT_#4829", "TRANSFER_LOG", "WALLET_KEY", "ROUTE_TABLE",
            "CIPHER_FRAG", "NODE_MAP_V2", "AUTH_TOKEN",
        },
        rare = {
            "MASTER_KEY_A", "ROOT_ACCESS", "VAULT_ENTRY", "ADMIN_CRED",
            "BLACKBOX_LOG", "PRIME_CIPHER",
        },
        jackpot = {
            "GENESIS_BLOCK", "CORE_DECRYPT", "OMEGA_SIGNAL", "DEEP_ARCHIVE",
        },
    }
    local pool = snippets[rarity] or snippets.basura
    return pool[math.random(#pool)]
end

function Lead:calculateReward(lead)
    return math.random(lead.reward_min, lead.reward_max)
end

function Lead:serialize()
    return {
        available_leads = self.available_leads,
        next_id = next_id,
    }
end

function Lead:deserialize(data)
    self.available_leads = data.available_leads or {}
    next_id = data.next_id or 1
end

return Lead
