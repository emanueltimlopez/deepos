local DesktopManager = {}
DesktopManager.__index = DesktopManager

function DesktopManager.new()
    local self = setmetatable({}, DesktopManager)
    self.icons = {}
    return self
end

function DesktopManager:addIcon(icon)
    table.insert(self.icons, icon)
end

function DesktopManager:getIcon(id)
    for _, icon in ipairs(self.icons) do
        if icon.id == id then return icon end
    end
    return nil
end

function DesktopManager:update(dt)
    local mx, my = love.mouse.getPosition()
    for _, icon in ipairs(self.icons) do
        icon.hover = icon:isInside(mx, my)
    end
end

function DesktopManager:mousepressed(mx, my, button)
    for _, icon in ipairs(self.icons) do
        if icon:isInside(mx, my) then
            icon:click()
            return true
        end
    end
    return false
end

function DesktopManager:draw()
    for _, icon in ipairs(self.icons) do
        icon:draw()
    end
end

return DesktopManager
