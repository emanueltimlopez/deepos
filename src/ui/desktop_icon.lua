local Theme = require("src.ui.theme")

local DesktopIcon = {}
DesktopIcon.__index = DesktopIcon

local ICON_SIZE = 48
local LABEL_GAP = 4
local TOTAL_W = 64
local TOTAL_H = ICON_SIZE + LABEL_GAP + 16

function DesktopIcon.new(id, x, y, label, callback)
    local self = setmetatable({}, DesktopIcon)
    self.id = id
    self.x = x
    self.y = y
    self.label = label
    self.callback = callback
    self.badge_count = 0
    self.hover = false
    return self
end

function DesktopIcon:isInside(mx, my)
    local cx = self.x - TOTAL_W / 2
    return mx >= cx and mx <= cx + TOTAL_W
       and my >= self.y and my <= self.y + TOTAL_H
end

function DesktopIcon:setBadge(count)
    self.badge_count = count
end

function DesktopIcon:click()
    if self.callback then
        self.callback()
    end
end

function DesktopIcon:draw()
    local font = love.graphics.getFont()

    -- Icon area centered on self.x
    local ix = self.x - ICON_SIZE / 2
    local iy = self.y

    -- Hover highlight
    if self.hover then
        love.graphics.setColor(0.0, 0.0, 0.0, 0.08)
        love.graphics.rectangle("fill", ix - 4, iy - 2, ICON_SIZE + 8, TOTAL_H + 4, 2, 2)
    end

    -- Icon background (white with beveled border)
    Theme.drawBeveledRect(ix, iy, ICON_SIZE, ICON_SIZE, Theme.colors.window_bg)

    -- Placeholder: first letter of label, large and centered
    love.graphics.setColor(Theme.colors.text)
    local letter = self.label:sub(1, 1):upper()
    local lw = font:getWidth(letter)
    local lh = font:getHeight()
    love.graphics.print(letter, ix + (ICON_SIZE - lw) / 2, iy + (ICON_SIZE - lh) / 2)

    -- Label below icon
    local label_w = font:getWidth(self.label)
    local lx = self.x - label_w / 2
    local ly = iy + ICON_SIZE + LABEL_GAP

    -- Label background (selected-style if hovered)
    if self.hover then
        love.graphics.setColor(Theme.colors.window_border)
        love.graphics.rectangle("fill", lx - 2, ly - 1, label_w + 4, lh + 2)
        love.graphics.setColor(Theme.colors.window_bg)
    else
        love.graphics.setColor(Theme.colors.text)
    end
    love.graphics.print(self.label, lx, ly)

    -- Badge
    if self.badge_count > 0 then
        Theme.drawBadge(ix + ICON_SIZE - 2, iy + 2, self.badge_count)
    end
end

return DesktopIcon
