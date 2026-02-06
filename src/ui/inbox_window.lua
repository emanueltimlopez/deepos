local Window = require("src.ui.window")
local Button = require("src.ui.button")
local Theme = require("src.ui.theme")

-- Patterns that look suspicious (for danger indicator)
local SUSPICIOUS_PATTERNS = {"00 00", "FF FF", "00 FF", "F0 0F"}

local function looksSuspicious(hex_preview)
    if not hex_preview then return false end
    for _, pat in ipairs(SUSPICIOUS_PATTERNS) do
        if hex_preview:find(pat, 1, true) then
            return true
        end
    end
    -- Check for high repetition of 0 and F
    local zeros = 0
    for _ in hex_preview:gmatch("0") do zeros = zeros + 1 end
    local effs = 0
    for _ in hex_preview:gmatch("F") do effs = effs + 1 end
    if (zeros + effs) > #hex_preview * 0.5 then
        return true
    end
    return false
end

local function createInboxWindow(lead_system, hardware, on_lead_click, on_trash)
    local sw = love.graphics.getWidth()

    local win = Window.new(
        "inbox",
        60, Theme.MENU_BAR_HEIGHT + 50,
        440, 380,
        "Inbox",
        -- content draw
        function(w, x, y, ww, hh)
            local leads = lead_system:getAvailableLeads()
            local font = love.graphics.getFont()
            local fh = font:getHeight()

            local has_danger = hardware:hasSoftware("threat_scanner")
            local has_value = hardware:hasSoftware("value_estimator")

            if #leads == 0 then
                love.graphics.setColor(Theme.colors.text_disabled)
                local msg = "No leads available"
                local tw = font:getWidth(msg)
                love.graphics.print(msg, x + (ww - tw) / 2, y + hh / 2 - fh / 2)
                return
            end

            -- Lead entries (up to 10)
            local ly = 12
            local entry_h = 32
            local max_display = 10
            for i, lead in ipairs(leads) do
                if i > max_display then break end
                local ey = y + ly

                if ey + entry_h > y + hh - 10 then break end

                -- Alternating row bg
                if i % 2 == 0 then
                    love.graphics.setColor(0.93, 0.93, 0.93, 1)
                    love.graphics.rectangle("fill", x + 5, ey, ww - 130, entry_h)
                end

                -- Danger indicator (requires Manual v2)
                if has_danger then
                    local suspicious = looksSuspicious(lead.hex_preview)
                    if suspicious then
                        love.graphics.setColor(0.7, 0.0, 0.0, 1.0)
                        love.graphics.print("!", x + 10, ey + 4)
                    end
                end

                -- Rarity tag
                local tag = lead.rarity:sub(1, 1):upper()
                love.graphics.setColor(Theme.colors.text_disabled)
                love.graphics.print("[" .. tag .. "]", x + 22, ey + 4)

                -- Lead info: cost always visible, reward gated
                local open_cost = lead.open_cost or 15
                love.graphics.setColor(Theme.colors.text)
                if has_value then
                    local info = string.format("#%d  Cost:%d  Reward:%d-%d",
                        lead.id, open_cost, lead.reward_min, lead.reward_max)
                    love.graphics.print(info, x + 48, ey + 4)
                else
                    local info = string.format("#%d  Cost:%d  Reward:???",
                        lead.id, open_cost)
                    love.graphics.print(info, x + 48, ey + 4)
                end

                -- Hex preview (smaller, below the info line)
                love.graphics.setColor(Theme.colors.text_disabled)
                local preview = lead.hex_preview or "??"
                love.graphics.print(preview, x + 48, ey + 18)

                ly = ly + entry_h
            end
        end,
        -- content update
        function(w, dt)
            w.buttons = {}
            local leads = lead_system:getAvailableLeads()
            local ly = 16
            local entry_h = 32
            local max_display = 10

            for i, lead in ipairs(leads) do
                if i > max_display then break end
                if ly + entry_h > w.h - 10 then break end

                local lead_ref = lead

                -- Open button
                local open_btn = Button.new(w.w - 120, ly, 50, entry_h - 6, "Open", function()
                    if on_lead_click then
                        on_lead_click(lead_ref)
                    end
                end)
                table.insert(w.buttons, open_btn)

                -- Trash button
                local trash_btn = Button.new(w.w - 64, ly, 50, entry_h - 6, "Trash", function()
                    lead_system:trashLead(lead_ref.id)
                    if on_trash then
                        on_trash(lead_ref)
                    end
                end)
                table.insert(w.buttons, trash_btn)

                ly = ly + entry_h
            end
        end
    )

    return win
end

return createInboxWindow
