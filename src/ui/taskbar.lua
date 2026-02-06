local Button = require("src.ui.button")
local Theme = require("src.ui.theme")

local Taskbar = {}
Taskbar.__index = Taskbar

local BAR_HEIGHT = 40

function Taskbar.new(economy, trace, lead_system, on_shop_click, on_lead_click)
    local self = setmetatable({}, Taskbar)
    self.economy = economy
    self.trace = trace
    self.lead_system = lead_system
    self.on_shop_click = on_shop_click
    self.on_lead_click = on_lead_click

    local sw = love.graphics.getWidth()
    local sh = love.graphics.getHeight()
    self.y = sh - BAR_HEIGHT

    self.shop_button = Button.new(sw - 100, self.y + 8, 90, 24, "Shop", on_shop_click)
    self.lead_buttons = {}
    self.notification_timer = 0
    self.notification_text = nil
    return self
end

function Taskbar:getHeight()
    return BAR_HEIGHT
end

function Taskbar:notify(text)
    self.notification_text = text
    self.notification_timer = 3.0
end

function Taskbar:update(dt)
    if self.notification_timer > 0 then
        self.notification_timer = self.notification_timer - dt
        if self.notification_timer <= 0 then
            self.notification_text = nil
        end
    end

    -- Rebuild lead buttons
    self.lead_buttons = {}
    local available = self.lead_system:getAvailableLeads()
    local bx = 300
    for i, lead in ipairs(available) do
        local color_label = lead.rarity == "jackpot" and "[J]" or
                            lead.rarity == "rare" and "[R]" or
                            lead.rarity == "standard" and "[S]" or "[B]"
        local lead_ref = lead
        local btn = Button.new(bx, self.y + 8, 60, 24, color_label .. lead.id,
            function()
                if self.on_lead_click then
                    self.on_lead_click(lead_ref)
                end
            end)
        table.insert(self.lead_buttons, btn)
        bx = bx + 65
        if i >= 6 then break end
    end

    -- Update hover
    local mx, my = love.mouse.getPosition()
    self.shop_button:updateHover(mx, my)
    for _, btn in ipairs(self.lead_buttons) do
        btn:updateHover(mx, my)
    end
end

function Taskbar:mousepressed(mx, my, button)
    if my < self.y then return false end

    if self.shop_button:isInside(mx, my) then
        self.shop_button:click()
        return true
    end

    for _, btn in ipairs(self.lead_buttons) do
        if btn:isInside(mx, my) then
            btn:click()
            return true
        end
    end

    return true -- consume click on taskbar area
end

function Taskbar:draw()
    local sw = love.graphics.getWidth()

    -- Bar background (Platinum grey)
    love.graphics.setColor(Theme.colors.control_strip)
    love.graphics.rectangle("fill", 0, self.y, sw, BAR_HEIGHT)

    -- Beveled top edge: white highlight line
    love.graphics.setColor(Theme.colors.highlight)
    love.graphics.line(0, self.y, sw, self.y)

    -- Dark line just below highlight
    love.graphics.setColor(Theme.colors.shadow)
    love.graphics.line(0, self.y + 1, sw, self.y + 1)

    -- Credits (black text)
    -- love.graphics.setColor(Theme.colors.text)
    -- love.graphics.print("CR: " .. self.economy:getCredits(), 10, self.y + 12)

    -- Trace bar with inset border
    local bar_x, bar_y, bar_w, bar_h = 120, self.y + 12, 100, 16

    -- Inset background
    love.graphics.setColor(Theme.colors.progress_bg)
    love.graphics.rectangle("fill", bar_x, bar_y, bar_w, bar_h)
    Theme.drawInsetRect(bar_x, bar_y, bar_w, bar_h)

    -- Trace fill
    local trace_pct = self.trace:getLevel()
    local tr = trace_pct > 0.7 and 0.8 or trace_pct > 0.4 and 0.6 or 0.3
    love.graphics.setColor(tr, 0.1, 0.1, 1)
    love.graphics.rectangle("fill", bar_x + 1, bar_y + 1, (bar_w - 2) * trace_pct, bar_h - 2)

    -- Trace label
    love.graphics.setColor(Theme.colors.text)
    love.graphics.print("Trace", 225, self.y + 12)

    -- Lead buttons
    for _, btn in ipairs(self.lead_buttons) do
        btn:draw()
    end

    -- Shop button
    self.shop_button:draw()

    -- Notification
    if self.notification_text then
        local alpha = math.min(self.notification_timer, 1.0)
        love.graphics.setColor(0.0, 0.0, 0.0, alpha)
        love.graphics.print(self.notification_text, sw / 2 - 80, self.y - 25)
    end
end

return Taskbar
