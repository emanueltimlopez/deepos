local Theme = require("src.ui.theme")

local Window = {}
Window.__index = Window

local TITLE_BAR_HEIGHT = Theme.TITLE_BAR_HEIGHT
local CLOSE_BOX_SIZE = 12

function Window.new(id, x, y, w, h, title, content_draw_fn, content_update_fn)
    local self = setmetatable({}, Window)
    self.id = id
    self.x = x
    self.y = y
    self.w = w
    self.h = h
    self.title = title or "Window"
    self.content_draw_fn = content_draw_fn
    self.content_update_fn = content_update_fn
    self.is_dragging = false
    self.offset_x = 0
    self.offset_y = 0
    self.visible = true
    self.close_button = true
    self.buttons = {}
    self.data = {}
    return self
end

function Window:getTitleBarHeight()
    return TITLE_BAR_HEIGHT
end

function Window:isInside(mx, my)
    return mx >= self.x and mx <= self.x + self.w
       and my >= self.y and my <= self.y + self.h + TITLE_BAR_HEIGHT
end

function Window:isInTitleBar(mx, my)
    return mx >= self.x and mx <= self.x + self.w
       and my >= self.y and my <= self.y + TITLE_BAR_HEIGHT
end

function Window:isInCloseButton(mx, my)
    if not self.close_button then return false end
    -- Mac style: close box on the left
    local bx = self.x + 6
    local by = self.y + (TITLE_BAR_HEIGHT - CLOSE_BOX_SIZE) / 2
    return mx >= bx and mx <= bx + CLOSE_BOX_SIZE and my >= by and my <= by + CLOSE_BOX_SIZE
end

function Window:mousepress(mx, my, button)
    if not self.visible then return false end

    if self:isInCloseButton(mx, my) then
        return "close"
    end

    if self:isInTitleBar(mx, my) then
        self.is_dragging = true
        self.offset_x = mx - self.x
        self.offset_y = my - self.y
        return true
    end

    -- Check buttons inside window
    local content_x = self.x
    local content_y = self.y + TITLE_BAR_HEIGHT
    for _, btn in ipairs(self.buttons) do
        local abs_x = content_x + btn.x
        local abs_y = content_y + btn.y
        if mx >= abs_x and mx <= abs_x + btn.w and my >= abs_y and my <= abs_y + btn.h then
            btn:click()
            return true
        end
    end

    if self:isInside(mx, my) then
        return true
    end

    return false
end

function Window:mouserelease()
    self.is_dragging = false
end

function Window:update(dt)
    if self.is_dragging then
        local mx, my = love.mouse.getPosition()
        self.x = mx - self.offset_x
        self.y = my - self.offset_y
        -- Clamp to screen
        self.x = math.max(0, math.min(self.x, love.graphics.getWidth() - self.w))
        self.y = math.max(Theme.MENU_BAR_HEIGHT, math.min(self.y, love.graphics.getHeight() - self.h - TITLE_BAR_HEIGHT))
    end

    -- Update hover state for buttons
    local mx, my = love.mouse.getPosition()
    local content_x = self.x
    local content_y = self.y + TITLE_BAR_HEIGHT
    for _, btn in ipairs(self.buttons) do
        local abs_x = content_x + btn.x
        local abs_y = content_y + btn.y
        btn.hover = mx >= abs_x and mx <= abs_x + btn.w and my >= abs_y and my <= abs_y + btn.h
    end

    if self.content_update_fn then
        self.content_update_fn(self, dt)
    end
end

function Window:draw()
    if not self.visible then return end

    -- Drop shadow
    love.graphics.setColor(0.0, 0.0, 0.0, 0.3)
    love.graphics.rectangle("fill", self.x + 2, self.y + 2, self.w, self.h + TITLE_BAR_HEIGHT)

    -- Title bar with System 7 stripes
    Theme.drawTitleBarStripes(self.x, self.y, self.w, TITLE_BAR_HEIGHT)

    -- Close box (left side, Mac style)
    if self.close_button then
        local bx = self.x + 6
        local by = self.y + (TITLE_BAR_HEIGHT - CLOSE_BOX_SIZE) / 2
        local mx, my = love.mouse.getPosition()
        local hover = mx >= bx and mx <= bx + CLOSE_BOX_SIZE and my >= by and my <= by + CLOSE_BOX_SIZE
        Theme.drawCloseBox(bx, by, hover)
    end

    -- Title text centered
    love.graphics.setColor(Theme.colors.text)
    local font = love.graphics.getFont()
    local tw = font:getWidth(self.title)
    love.graphics.print(self.title, self.x + (self.w - tw) / 2, self.y + 5)

    -- Window body (white)
    love.graphics.setColor(Theme.colors.window_bg)
    love.graphics.rectangle("fill", self.x, self.y + TITLE_BAR_HEIGHT, self.w, self.h)

    -- Outer border (black)
    love.graphics.setColor(Theme.colors.window_border)
    love.graphics.rectangle("line", self.x, self.y, self.w, self.h + TITLE_BAR_HEIGHT)

    -- Content with scissor
    love.graphics.setScissor(self.x + 1, self.y + TITLE_BAR_HEIGHT + 1, self.w - 2, self.h - 2)

    if self.content_draw_fn then
        self.content_draw_fn(self, self.x, self.y + TITLE_BAR_HEIGHT, self.w, self.h)
    end

    -- Draw buttons
    love.graphics.setScissor()
    local content_x = self.x
    local content_y = self.y + TITLE_BAR_HEIGHT
    for _, btn in ipairs(self.buttons) do
        local old_x, old_y = btn.x, btn.y
        btn.x = content_x + btn.x
        btn.y = content_y + btn.y
        btn:draw()
        btn.x = old_x
        btn.y = old_y
    end

    love.graphics.setScissor()
end

return Window
