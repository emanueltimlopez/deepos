local Theme = require("src.ui.theme")

local NotificationManager = {}
NotificationManager.__index = NotificationManager

local MAX_VISIBLE = 5
local DURATION = 3.0
local PADDING_H = 8
local PADDING_V = 4

function NotificationManager.new()
    local self = setmetatable({}, NotificationManager)
    self.notifications = {}
    return self
end

function NotificationManager:notify(text)
    table.insert(self.notifications, {
        text = text,
        timer = DURATION,
        alpha = 1.0,
    })
    -- Cap visible notifications
    while #self.notifications > MAX_VISIBLE do
        table.remove(self.notifications, 1)
    end
end

function NotificationManager:update(dt)
    for i = #self.notifications, 1, -1 do
        local n = self.notifications[i]
        n.timer = n.timer - dt
        if n.timer <= 0 then
            table.remove(self.notifications, i)
        elseif n.timer < 1.0 then
            n.alpha = n.timer
        else
            n.alpha = 1.0
        end
    end
end

function NotificationManager:draw()
    local sw = love.graphics.getWidth()
    local sh = love.graphics.getHeight()
    local font = love.graphics.getFont()
    local fh = font:getHeight()
    local box_h = fh + PADDING_V * 2
    local base_y = sh - 30

    for i, n in ipairs(self.notifications) do
        local tw = font:getWidth(n.text)
        local box_w = tw + PADDING_H * 2
        local bx = (sw - box_w) / 2
        local by = base_y - (i * (box_h + 4))

        -- Drop shadow
        love.graphics.setColor(0.0, 0.0, 0.0, 0.15 * n.alpha)
        love.graphics.rectangle("fill", bx + 2, by + 2, box_w, box_h)

        -- Background
        love.graphics.setColor(1.0, 1.0, 1.0, n.alpha)
        love.graphics.rectangle("fill", bx, by, box_w, box_h)

        -- Border
        love.graphics.setColor(0.0, 0.0, 0.0, n.alpha * 0.6)
        love.graphics.rectangle("line", bx, by, box_w, box_h)

        -- Text
        love.graphics.setColor(0.0, 0.0, 0.0, n.alpha)
        love.graphics.print(n.text, bx + PADDING_H, by + PADDING_V)
    end
end

return NotificationManager
