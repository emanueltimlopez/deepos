local Theme = require("src.ui.theme")

local Button = {}
Button.__index = Button

function Button.new(x, y, w, h, label, onClick)
    local self = setmetatable({}, Button)
    self.x = x
    self.y = y
    self.w = w
    self.h = h
    self.label = label
    self.onClick = onClick
    self.hover = false
    self.visible = true
    return self
end

function Button:isInside(mx, my)
    return mx >= self.x and mx <= self.x + self.w
       and my >= self.y and my <= self.y + self.h
end

function Button:updateHover(mx, my)
    self.hover = self:isInside(mx, my)
end

function Button:click()
    if self.onClick then
        self.onClick()
    end
end

function Button:draw()
    if not self.visible then return end

    local face = self.hover and Theme.colors.button_hover or Theme.colors.button_face
    Theme.drawBeveledRect(self.x, self.y, self.w, self.h, face)

    -- Text centered, black
    love.graphics.setColor(Theme.colors.text)
    local font = love.graphics.getFont()
    local tw = font:getWidth(self.label)
    local th = font:getHeight()
    love.graphics.print(self.label, self.x + (self.w - tw) / 2, self.y + (self.h - th) / 2)
end

return Button
