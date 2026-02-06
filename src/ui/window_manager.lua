local WindowManager = {}
WindowManager.__index = WindowManager

function WindowManager.new()
    local self = setmetatable({}, WindowManager)
    self.windows = {}
    return self
end

function WindowManager:addWindow(win)
    table.insert(self.windows, win)
end

function WindowManager:removeWindow(id)
    for i = #self.windows, 1, -1 do
        if self.windows[i].id == id then
            table.remove(self.windows, i)
            return true
        end
    end
    return false
end

function WindowManager:getWindow(id)
    for _, win in ipairs(self.windows) do
        if win.id == id then return win end
    end
    return nil
end

function WindowManager:bringToFront(win)
    for i, w in ipairs(self.windows) do
        if w == win then
            table.remove(self.windows, i)
            table.insert(self.windows, win)
            return
        end
    end
end

function WindowManager:getWindowCount()
    return #self.windows
end

function WindowManager:mousepressed(mx, my, button)
    -- Iterate from top (last) to bottom (first) for proper z-order
    for i = #self.windows, 1, -1 do
        local win = self.windows[i]
        local result = win:mousepress(mx, my, button)
        if result == "close" then
            self:removeWindow(win.id)
            return true
        elseif result then
            self:bringToFront(win)
            return true
        end
    end
    return false
end

function WindowManager:mousereleased(mx, my, button)
    for _, win in ipairs(self.windows) do
        win:mouserelease()
    end
end

function WindowManager:update(dt)
    for _, win in ipairs(self.windows) do
        win:update(dt)
    end
end

function WindowManager:draw()
    for _, win in ipairs(self.windows) do
        win:draw()
    end
end

return WindowManager
