local Theme = {}

-- Platinum palette
Theme.colors = {
    -- Window chrome
    titlebar     = {0.75, 0.75, 0.75},
    titlebar_active = {0.75, 0.75, 0.75},
    window_bg    = {1.0, 1.0, 1.0},
    window_border = {0.0, 0.0, 0.0},

    -- Bevels
    highlight    = {1.0, 1.0, 1.0},
    shadow       = {0.5, 0.5, 0.5},
    dark_shadow  = {0.33, 0.33, 0.33},

    -- Buttons
    button_face  = {0.75, 0.75, 0.75},
    button_hover = {0.82, 0.82, 0.82},

    -- Text
    text         = {0.0, 0.0, 0.0},
    text_disabled = {0.5, 0.5, 0.5},

    -- Desktop
    desktop      = {0.75, 0.75, 0.75},

    -- Control Strip (kept for reference)
    control_strip = {0.75, 0.75, 0.75},

    -- Progress bar
    progress_fill = {0.25, 0.35, 0.7},
    progress_bg   = {1.0, 1.0, 1.0},

    -- Alerts
    alert_bg     = {1.0, 1.0, 1.0},
    alert_danger = {0.0, 0.0, 0.0},
}

Theme.MENU_BAR_HEIGHT = 20
Theme.TITLE_BAR_HEIGHT = 24

-- Desktop dither pattern canvas (pre-rendered)
Theme._desktop_canvas = nil

function Theme.drawBeveledRect(x, y, w, h, face_color, pressed)
    -- Face
    love.graphics.setColor(face_color or Theme.colors.button_face)
    love.graphics.rectangle("fill", x, y, w, h)

    if pressed then
        -- Pressed: dark top-left, light bottom-right
        love.graphics.setColor(Theme.colors.shadow)
        love.graphics.line(x, y, x + w - 1, y)         -- top
        love.graphics.line(x, y, x, y + h - 1)         -- left
        love.graphics.setColor(Theme.colors.highlight)
        love.graphics.line(x + w, y + h, x, y + h)     -- bottom
        love.graphics.line(x + w, y + h, x + w, y)     -- right
    else
        -- Normal: light top-left, dark bottom-right
        love.graphics.setColor(Theme.colors.highlight)
        love.graphics.line(x, y, x + w - 1, y)         -- top
        love.graphics.line(x, y, x, y + h - 1)         -- left
        love.graphics.setColor(Theme.colors.shadow)
        love.graphics.line(x + w, y + h, x, y + h)     -- bottom
        love.graphics.line(x + w, y + h, x + w, y)     -- right
    end

    -- Outer border
    love.graphics.setColor(Theme.colors.window_border)
    love.graphics.rectangle("line", x, y, w, h)
end

function Theme.drawInsetRect(x, y, w, h)
    -- Sunken area: dark top-left, light bottom-right
    love.graphics.setColor(Theme.colors.shadow)
    love.graphics.line(x, y, x + w - 1, y)         -- top
    love.graphics.line(x, y, x, y + h - 1)         -- left
    love.graphics.setColor(Theme.colors.highlight)
    love.graphics.line(x + w, y + h, x, y + h)     -- bottom
    love.graphics.line(x + w, y + h, x + w, y)     -- right
end

function Theme.drawTitleBarStripes(x, y, w, h)
    -- System 7 horizontal stripe pattern in title bar
    love.graphics.setColor(Theme.colors.titlebar)
    love.graphics.rectangle("fill", x, y, w, h)

    -- Horizontal lines across the title bar (classic Mac look)
    for ly = y + 2, y + h - 2, 2 do
        love.graphics.setColor(Theme.colors.highlight)
        love.graphics.line(x + 2, ly, x + w - 2, ly)
        love.graphics.setColor(Theme.colors.shadow)
        love.graphics.line(x + 2, ly + 1, x + w - 2, ly + 1)
    end
end

function Theme.drawCloseBox(x, y, hover)
    -- Mac System 7 close box: small square on the left of title bar
    local size = 12
    local bx = x
    local by = y

    love.graphics.setColor(Theme.colors.window_bg)
    love.graphics.rectangle("fill", bx, by, size, size)

    love.graphics.setColor(Theme.colors.window_border)
    love.graphics.rectangle("line", bx, by, size, size)

    if hover then
        -- Inner square when hovered (Mac-style visual feedback)
        love.graphics.rectangle("line", bx + 3, by + 3, size - 6, size - 6)
    end
end

function Theme.drawBadge(x, y, count)
    local radius = 8
    love.graphics.setColor(0.8, 0.0, 0.0, 1.0)
    love.graphics.circle("fill", x, y, radius)
    love.graphics.setColor(Theme.colors.window_border)
    love.graphics.circle("line", x, y, radius)
    love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
    local font = love.graphics.getFont()
    local text = tostring(count)
    local tw = font:getWidth(text)
    local th = font:getHeight()
    love.graphics.print(text, x - tw / 2, y - th / 2)
end

function Theme.getDesktopCanvas()
    if Theme._desktop_canvas then
        return Theme._desktop_canvas
    end

    local sw = love.graphics.getWidth()
    local sh = love.graphics.getHeight()
    Theme._desktop_canvas = love.graphics.newCanvas(sw, sh)

    love.graphics.setCanvas(Theme._desktop_canvas)
    love.graphics.clear()

    -- Solid grey base
    love.graphics.setColor(Theme.colors.desktop)
    love.graphics.rectangle("fill", 0, 0, sw, sh)

    -- Classic Mac dither pattern (checkerboard dots)
    love.graphics.setColor(0.70, 0.70, 0.70)
    for y = 0, sh, 2 do
        for x = 0, sw, 2 do
            if (x + y) % 4 == 0 then
                love.graphics.points(x, y)
            end
        end
    end

    love.graphics.setCanvas()
    return Theme._desktop_canvas
end

function Theme.drawMenuBar(sw, economy, trace)
    local h = Theme.MENU_BAR_HEIGHT

    -- Menu bar background
    love.graphics.setColor(Theme.colors.control_strip)
    love.graphics.rectangle("fill", 0, 0, sw, h)

    -- Bottom border
    love.graphics.setColor(Theme.colors.window_border)
    love.graphics.line(0, h, sw, h)

    -- Apple-style logo placeholder
    love.graphics.setColor(Theme.colors.text)
    local font = love.graphics.getFont()
    love.graphics.print("@", 8, 3)


    -- Right side: Credits → Trace → Clock
    local rx = sw - 10

    -- Clock (rightmost)
    local clock = os.date("%I:%M %p")
    local cw = font:getWidth(clock)
    rx = rx - cw
    love.graphics.setColor(Theme.colors.text)
    love.graphics.print(clock, rx, 3)

    -- Trace mini-bar
    -- rx = rx - 65
    -- local bar_x, bar_y, bar_w, bar_h = rx, 5, 50, 10
    -- love.graphics.setColor(Theme.colors.progress_bg)
    -- love.graphics.rectangle("fill", bar_x, bar_y, bar_w, bar_h)
    -- Theme.drawInsetRect(bar_x, bar_y, bar_w, bar_h)

    -- if trace then
    --     local trace_pct = trace:getLevel()
    --     local tr = trace_pct > 0.7 and 0.8 or trace_pct > 0.4 and 0.6 or 0.3
    --     love.graphics.setColor(tr, 0.1, 0.1, 1)
    --     love.graphics.rectangle("fill", bar_x + 1, bar_y + 1, (bar_w - 2) * trace_pct, bar_h - 2)
    -- end

    -- "T:" label before trace bar
    -- rx = rx - 16
    -- love.graphics.setColor(Theme.colors.text)
    -- love.graphics.print("T:", rx, 3)

    -- Credits
    if economy then
        local credits_text = "CR:" .. economy:getCredits()
        local ctw = font:getWidth(credits_text)
        rx = rx - ctw - 12
        love.graphics.print(credits_text, rx, 3)
    end
end

return Theme
