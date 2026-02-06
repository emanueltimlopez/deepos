local StateManager = require("src.state_manager")
local WindowManager = require("src.ui.window_manager")
local Window = require("src.ui.window")
local Button = require("src.ui.button")
local Theme = require("src.ui.theme")
local DesktopIcon = require("src.ui.desktop_icon")
local DesktopManager = require("src.ui.desktop_manager")
local NotificationManager = require("src.ui.notification")
local createInboxWindow = require("src.ui.inbox_window")
local createNetLedgerWindow = require("src.ui.netledger_window")
local createTunePlayerWindow = require("src.ui.tuneplayer_window")
local HexDecrypter = require("src.systems.hex_decrypter")
local LeadSystem = require("src.systems.lead")
local Hardware = require("src.systems.hardware")
local Economy = require("src.systems.economy")
local Trace = require("src.systems.trace")
local Save = require("src.systems.save")
local AudioManager = require("src.audio.audio_manager")
local Manual = require("src.systems.manual")
local MusicPlayer = require("src.systems.music_player")

local state_manager
local crt_shader
local time = 0
local canvas

-- ============================================================
-- MENU STATE
-- ============================================================
local MenuState = {}
MenuState.__index = MenuState

function MenuState.new(sm)
    local self = setmetatable({}, MenuState)
    self.sm = sm
    self.blink_timer = 0
    self.show_text = true
    self.title_font = love.graphics.newFont("assets/fonts/PressStart2P.ttf", 28)
    self.sub_font = love.graphics.newFont("assets/fonts/PressStart2P.ttf", 10)
    return self
end

function MenuState:enter() end
function MenuState:exit() end

function MenuState:update(dt)
    self.blink_timer = self.blink_timer + dt
    if self.blink_timer >= 0.6 then
        self.blink_timer = 0
        self.show_text = not self.show_text
    end
end

function MenuState:draw()
    local sw = love.graphics.getWidth()
    local sh = love.graphics.getHeight()

    -- Platinum grey background
    love.graphics.setColor(Theme.colors.desktop)
    love.graphics.rectangle("fill", 0, 0, sw, sh)

    local font = love.graphics.getFont()

    -- Centered Mac-style dialog box
    local box_w = 420
    local box_h = 200
    local box_x = (sw - box_w) / 2
    local box_y = (sh - box_h) / 2

    -- Drop shadow
    love.graphics.setColor(0.0, 0.0, 0.0, 0.25)
    love.graphics.rectangle("fill", box_x + 3, box_y + 3, box_w, box_h)

    -- White dialog body
    love.graphics.setColor(Theme.colors.alert_bg)
    love.graphics.rectangle("fill", box_x, box_y, box_w, box_h)

    -- Double border (classic Mac)
    love.graphics.setColor(Theme.colors.window_border)
    love.graphics.rectangle("line", box_x, box_y, box_w, box_h)
    love.graphics.rectangle("line", box_x + 2, box_y + 2, box_w - 4, box_h - 4)

    -- Title: "DEEP" in retro pixel font
    love.graphics.setFont(self.title_font)
    love.graphics.setColor(Theme.colors.text)
    local title = "DEEP"
    local tw = self.title_font:getWidth(title)
    love.graphics.print(title, box_x + (box_w - tw) / 2, box_y + 30)

    -- "OS" subtitle in smaller retro font
    love.graphics.setFont(self.sub_font)
    love.graphics.setColor(Theme.colors.text_disabled)
    local sub = "O P E R A T I N G  S Y S T E M"
    local stw = self.sub_font:getWidth(sub)
    love.graphics.print(sub, box_x + (box_w - stw) / 2, box_y + 72)

    -- Restore normal font
    love.graphics.setFont(font)

    -- Divider line
    local divider_y = box_y + 100
    love.graphics.setColor(Theme.colors.shadow)
    love.graphics.line(box_x + 20, divider_y, box_x + box_w - 20, divider_y)

    -- Blink prompt
    if self.show_text then
        love.graphics.setColor(Theme.colors.text)
        local prompt = "Press Enter to boot"
        local pw = font:getWidth(prompt)
        love.graphics.print(prompt, box_x + (box_w - pw) / 2, divider_y + 25)
    end

    -- Version
    love.graphics.setColor(Theme.colors.text_disabled)
    love.graphics.print("v0.1.0", box_x + (box_w - font:getWidth("v0.1.0")) / 2, box_y + box_h - 25)
end

function MenuState:keypressed(key)
    if key == "return" then
        self.sm:switch("game")
    end
end

function MenuState:mousepressed(x, y, button) end
function MenuState:mousereleased(x, y, button) end

-- ============================================================
-- GAME STATE
-- ============================================================
local GameState = {}
GameState.__index = GameState

function GameState.new(sm)
    local self = setmetatable({}, GameState)
    self.sm = sm
    self.window_manager = WindowManager.new()
    self.economy = Economy.new(0)
    self.hardware = Hardware.new()
    self.trace = Trace.new()
    self.lead_system = LeadSystem.new()
    self.audio = AudioManager.new()
    self.manual = Manual.new()
    self.music_player = MusicPlayer.new()

    self.active_decrypters = {} -- lead_id -> HexDecrypter
    self.raid_cooldown = 0
    self.raid_message = nil
    self.crash_message = nil
    self._alert_ok_rect = nil
    self.shop_open = false
    self.inbox_open = false
    self.manual_open = false
    self.netledger_open = false
    self.tuneplayer_open = false
    self.manual_page = 1
    self.next_window_id = 1

    -- Notification system
    self.notifications = NotificationManager.new()

    -- Desktop icons
    self.desktop_manager = DesktopManager.new()
    local sw = love.graphics.getWidth()

    self.desktop_manager:addIcon(DesktopIcon.new(
        "inbox",
        sw - 45, Theme.MENU_BAR_HEIGHT + 50,
        "Inbox",
        function() self:toggleInbox() end
    ))

    self.desktop_manager:addIcon(DesktopIcon.new(
        "shop",
        sw - 45, Theme.MENU_BAR_HEIGHT + 140,
        "Shop",
        function() self:toggleShop() end
    ))

    self.desktop_manager:addIcon(DesktopIcon.new(
        "manual",
        sw - 45, Theme.MENU_BAR_HEIGHT + 230,
        "Manual",
        function() self:toggleManual() end
    ))

    self.desktop_manager:addIcon(DesktopIcon.new(
        "netledger",
        sw - 45, Theme.MENU_BAR_HEIGHT + 320,
        "Bank",
        function() self:toggleNetLedger() end
    ))

    self.desktop_manager:addIcon(DesktopIcon.new(
        "tuneplayer",
        sw - 45, Theme.MENU_BAR_HEIGHT + 410,
        "Music",
        function() self:toggleTunePlayer() end
    ))

    -- Try loading save
    local save_data = Save.load()
    if save_data then
        self.economy:deserialize(save_data.economy)
        self.hardware:deserialize(save_data.hardware)
        self.trace:deserialize(save_data.trace)
        self.lead_system:deserialize(save_data.leads)
        if save_data.manual then
            self.manual:deserialize(save_data.manual)
        end
        if save_data.music_player then
            self.music_player:deserialize(save_data.music_player)
        end
    else
        -- First boot: add welcome message to inbox
        local welcome = {
            id = 0,
            rarity = "standard",
            display_rarity = "standard",
            reward_min = 150,
            reward_max = 150,
            security_level = 1,
            open_cost = 0,
            hex_data = self:generateWelcomeHex(),
            real_data = "WELCOME_MSG",
            data_size = 64,
            is_virus = false,
            virus_pattern = nil,
            snapshot_fidelity = true,
            hex_preview = "57 45 4C 43 4F 4D 45 21",
            is_welcome = true,
        }
        table.insert(self.lead_system:getAvailableLeads(), 1, welcome)
    end

    return self
end

function GameState:generateWelcomeHex()
    -- "WELCOME TO DEEP OS - GOOD LUCK OPERATOR" encoded as hex chars
    local msg = "WELCOME TO DEEP OS - GOOD LUCK OPERATOR"
    local data = {}
    for i = 1, 64 do
        if i <= #msg then
            local byte = string.byte(msg, i)
            local hex = string.format("%02X", byte)
            data[#data + 1] = hex:sub(1, 1)
            data[#data + 1] = hex:sub(2, 2)
        end
    end
    -- Pad remaining with dots
    while #data < 64 do
        data[#data + 1] = "0"
    end
    return data
end

function GameState:enter()
    self.lead_system:setMaxLeads(self.hardware:getMaxLeads())
    self:updateInboxBadge()
    self:syncManualLevel()
end

function GameState:exit() end

function GameState:getNextWindowId()
    local id = self.next_window_id
    self.next_window_id = self.next_window_id + 1
    return "win_" .. id
end

function GameState:updateInboxBadge()
    local inbox_icon = self.desktop_manager:getIcon("inbox")
    if inbox_icon then
        inbox_icon:setBadge(#self.lead_system:getAvailableLeads())
    end
end

function GameState:syncManualLevel()
    local level = 1
    if self.hardware:hasSoftware("manual_v2") then level = 2 end
    if self.hardware:hasSoftware("manual_v3") then level = 3 end
    self.manual:setLevel(level)
end

function GameState:virusCrash()
    -- Close ALL windows
    local to_remove = {}
    for _, win in ipairs(self.window_manager.windows) do
        table.insert(to_remove, win.id)
    end
    for _, id in ipairs(to_remove) do
        self.window_manager:removeWindow(id)
    end

    -- Clear all decrypters
    self.active_decrypters = {}

    -- Clear inbox leads
    local leads = self.lead_system:getAvailableLeads()
    for i = #leads, 1, -1 do
        table.remove(leads, i)
    end

    -- Steal everything, leave 50 CR
    local stolen = math.max(0, self.economy:getCredits() - 50)
    self.economy:spendCredits(stolen, "Virus attack")

    -- Reset state flags
    self.shop_open = false
    self.inbox_open = false
    self.manual_open = false
    self.netledger_open = false
    self.tuneplayer_open = false

    -- Show crash dialog
    self.crash_message = string.format("VIRUS EXECUTED! Stole %d CR. Balance: 50 CR.", stolen)
    self.crash_cooldown = 0 -- stays until dismissed

    self:updateInboxBadge()
end

function GameState:openDecrypterWindow(lead)
    -- Welcome message: special window
    if lead.is_welcome then
        self.lead_system:removeLead(lead.id)
        self:updateInboxBadge()
        local win_id = self:getNextWindowId()
        local win = Window.new(
            win_id,
            120, Theme.MENU_BAR_HEIGHT + 60,
            420, 280,
            "Message from HQ",
            function(w, x, y, ww, hh)
                local font = love.graphics.getFont()
                local fh = font:getHeight()
                local lines = {
                    "Operator,",
                    "",
                    "Welcome to DEEP OS.",
                    "",
                    "Your job is simple: intercept data",
                    "leads, decrypt them, extract value.",
                    "",
                    "Be careful. Some leads are junk,",
                    "some carry viruses. Read the Manual.",
                    "Trust your instincts. Watch the hex.",
                    "",
                    "Good luck. You'll need it.",
                    "",
                    "- HQ",
                }
                love.graphics.setColor(Theme.colors.text)
                for i, line in ipairs(lines) do
                    love.graphics.print(line, x + 16, y + 10 + (i - 1) * fh)
                end
            end,
            function(w, dt)
                w.buttons = {}
                local btn = Button.new(w.w / 2 - 40, w.h - 34, 80, 24, "OK", function()
                    self.economy:addCredits(100, "Welcome bonus")
                    self.notifications:notify("Welcome bonus: +100 CR")
                    self.window_manager:removeWindow(win_id)
                end)
                table.insert(w.buttons, btn)
            end
        )
        self.window_manager:addWindow(win)
        return
    end

    -- Check max windows
    if self.window_manager:getWindowCount() >= self.hardware:getMaxWindows() then
        self.notifications:notify("Max windows reached - Upgrade RAM")
        return
    end

    -- Remove lead from available (free to open)
    self.lead_system:removeLead(lead.id)
    self:updateInboxBadge()

    -- Create decrypter in preview mode (not started)
    local decrypter = HexDecrypter.new(lead)
    local lead_id = lead.id
    local cost = lead.open_cost or 15

    local win_id = self:getNextWindowId()

    -- Place window with offset, below menu bar
    local offset = (self.window_manager:getWindowCount()) * 30
    local win = Window.new(
        win_id,
        100 + offset, Theme.MENU_BAR_HEIGHT + 30 + offset,
        520, 380,
        string.format("Lead #%d [%s]", lead.id, lead.rarity:upper()),
        -- content draw
        function(w, x, y, ww, hh)
            decrypter:draw(x, y, ww, hh)
        end,
        -- content update
        function(w, dt)
            w.buttons = {}

            if not decrypter:isStarted() then
                -- Preview mode: Process and Delete buttons
                local process_btn = Button.new(w.w / 2 - 110, w.h - 34, 100, 24,
                    "Process " .. cost, function()
                    if not self.economy:canAfford(cost) then
                        self.notifications:notify("Not enough credits (" .. cost .. " CR)")
                        return
                    end
                    self.economy:spendCredits(cost, "Process lead #" .. lead.id)
                    decrypter:start()
                    self.active_decrypters[lead_id] = decrypter
                    w.title = string.format("Hex Decrypt - Lead #%d [%s]", lead.id, lead.rarity:upper())
                    self.notifications:notify("Processing... paid " .. cost .. " CR")
                end)
                table.insert(w.buttons, process_btn)

                local delete_btn = Button.new(w.w / 2 + 10, w.h - 34, 100, 24, "Delete", function()
                    self.window_manager:removeWindow(win_id)
                end)
                table.insert(w.buttons, delete_btn)
            else
                -- Decrypting mode
                decrypter:update(dt, self.hardware:getDecryptSpeed())

                -- Check virus execution
                if decrypter:isVirusExecuted() then
                    self:virusCrash()
                    return
                end

                -- Abort button
                if not decrypter:isComplete() and not decrypter:isAborted() then
                    local abort_label = decrypter:isVirusRevealed() and "ABORT!" or "Abort"
                    local abort_btn = Button.new(10, w.h - 34, 80, 24, abort_label, function()
                        decrypter:abort()
                        if not lead.is_virus then
                            self.notifications:notify("Aborted - decrypt failed")
                        else
                            self.notifications:notify("Virus aborted! System safe.")
                        end
                        self.window_manager:removeWindow(win_id)
                        self.active_decrypters[lead_id] = nil
                    end)
                    table.insert(w.buttons, abort_btn)
                end

                -- Extract button
                if decrypter:isComplete() then
                    local extract_btn = Button.new(w.w / 2 - 50, w.h - 38, 100, 28, "Extract", function()
                        local reward = self.lead_system:calculateReward(lead)
                        self.economy:addCredits(reward, "Extract lead #" .. lead.id)
                        self.notifications:notify("Extracted: +" .. reward .. " CR")
                        self.window_manager:removeWindow(win_id)
                        self.active_decrypters[lead_id] = nil
                    end)
                    table.insert(w.buttons, extract_btn)
                end
            end
        end
    )

    -- Store lead rarity info on the window for trace jackpot calculation
    win.data.lead_rarity = lead.rarity

    self.window_manager:addWindow(win)
end

function GameState:toggleInbox()
    if self.inbox_open then
        self.window_manager:removeWindow("inbox")
        self.inbox_open = false
        return
    end

    self.inbox_open = true
    local win = createInboxWindow(
        self.lead_system,
        self.hardware,
        function(lead) self:openDecrypterWindow(lead) end,
        function(lead)
            self.notifications:notify("Trashed lead #" .. lead.id)
            self:updateInboxBadge()
        end
    )
    self.window_manager:addWindow(win)
end

function GameState:toggleShop()
    if self.shop_open then
        self.window_manager:removeWindow("shop")
        self.shop_open = false
        return
    end

    self.shop_open = true
    local sw = love.graphics.getWidth()

    local win = Window.new(
        "shop",
        sw / 2 - 200, Theme.MENU_BAR_HEIGHT + 40,
        500, 420,
        "Online Shop",
        -- draw
        function(w, x, y, ww, hh)
            love.graphics.setColor(Theme.colors.text)
            love.graphics.print("Upgrade Your Hardware", x + 10, y + 10)

            love.graphics.setColor(Theme.colors.text_disabled)
            love.graphics.print("Credits: " .. self.economy:getCredits() .. " CR", x + 10, y + 30)

            local components = self.hardware:getComponentList()
            local by = 60
            for _, comp in ipairs(components) do
                love.graphics.setColor(Theme.colors.text)
                love.graphics.print(
                    string.format("%s  Lv.%d  [%d CR]", comp.label, comp.level, comp.cost),
                    x + 10, y + by
                )
                by = by + 30
            end

            -- Software section
            by = by + 15
            love.graphics.setColor(Theme.colors.shadow)
            love.graphics.line(x + 10, y + by, x + ww - 10, y + by)
            by = by + 8

            love.graphics.setColor(Theme.colors.text)
            love.graphics.print("Software Upgrades", x + 10, y + by)
            by = by + 24

            local software = self.hardware:getSoftwareList()
            for _, sw_item in ipairs(software) do
                if sw_item.owned then
                    love.graphics.setColor(Theme.colors.text_disabled)
                    love.graphics.print(
                        string.format("%s  [OWNED]  %s", sw_item.label, sw_item.description),
                        x + 10, y + by
                    )
                else
                    love.graphics.setColor(Theme.colors.text)
                    love.graphics.print(
                        string.format("%s  [%d CR]  %s", sw_item.label, sw_item.cost, sw_item.description),
                        x + 10, y + by
                    )
                end
                by = by + 30
            end
        end,
        -- update
        function(w, dt)
            w.buttons = {}
            local components = self.hardware:getComponentList()
            local by = 55
            for _, comp in ipairs(components) do
                local comp_name = comp.name
                local btn = Button.new(320, by, 60, 22, "Buy", function()
                    if self.hardware:upgrade(comp_name, self.economy) then
                        self.notifications:notify(comp_name:upper() .. " upgraded!")
                        self.lead_system:setMaxLeads(self.hardware:getMaxLeads())
                    else
                        self.notifications:notify("Not enough credits")
                    end
                end)
                table.insert(w.buttons, btn)
                by = by + 30
            end

            -- Software buttons
            by = by + 15 + 8 + 24 -- match the draw offset
            local software = self.hardware:getSoftwareList()
            for _, sw_item in ipairs(software) do
                if not sw_item.owned then
                    local sw_name = sw_item.name
                    local btn = Button.new(320, by, 60, 22, "Buy", function()
                        if self.hardware:buySoftware(sw_name, self.economy) then
                            self.notifications:notify(sw_item.label .. " acquired!")
                            self:syncManualLevel()
                        else
                            self.notifications:notify("Not enough credits")
                        end
                    end)
                    table.insert(w.buttons, btn)
                end
                by = by + 30
            end
        end
    )

    self.window_manager:addWindow(win)
end

function GameState:toggleManual()
    if self.manual_open then
        self.window_manager:removeWindow("manual")
        self.manual_open = false
        return
    end

    self.manual_open = true
    self.manual_page = 1

    local win = Window.new(
        "manual",
        180, Theme.MENU_BAR_HEIGHT + 60,
        380, 600,
        "Manual.txt",
        -- draw
        function(w, x, y, ww, hh)
            local pages = self.manual:getPages()
            local page = pages[self.manual_page]
            if not page then
                love.graphics.setColor(Theme.colors.text_disabled)
                love.graphics.print("No content available", x + 10, y + 10)
                return
            end

            -- Page title
            love.graphics.setColor(Theme.colors.text)
            love.graphics.print(page.title, x + 10, y + 10)

            -- Separator
            love.graphics.setColor(Theme.colors.shadow)
            love.graphics.line(x + 10, y + 28, x + ww - 10, y + 28)

            -- Content lines
            local ly = 36
            local font = love.graphics.getFont()
            local line_h = font:getHeight() + 2
            for _, line in ipairs(page.lines) do
                if y + ly + line_h > y + hh - 40 then break end
                love.graphics.setColor(Theme.colors.text)
                love.graphics.print(line, x + 10, y + ly)
                ly = ly + line_h
            end

            -- Page indicator
            love.graphics.setColor(Theme.colors.text_disabled)
            love.graphics.print(
                string.format("Page %d / %d", self.manual_page, self.manual:getPageCount()),
                x + 10, y + hh - 30
            )
        end,
        -- update
        function(w, dt)
            w.buttons = {}
            local page_count = self.manual:getPageCount()

            if self.manual_page > 1 then
                local btn = Button.new(10, w.h - 34, 80, 24, "Prev", function()
                    self.manual_page = self.manual_page - 1
                end)
                table.insert(w.buttons, btn)
            end

            if self.manual_page < page_count then
                local btn = Button.new(w.w - 90, w.h - 34, 80, 24, "Next", function()
                    self.manual_page = self.manual_page + 1
                end)
                table.insert(w.buttons, btn)
            end
        end
    )

    self.window_manager:addWindow(win)
end

function GameState:toggleNetLedger()
    if self.netledger_open then
        self.window_manager:removeWindow("netledger")
        self.netledger_open = false
        return
    end

    self.netledger_open = true
    local win = createNetLedgerWindow(self.economy)
    self.window_manager:addWindow(win)
end

function GameState:toggleTunePlayer()
    if self.tuneplayer_open then
        self.window_manager:removeWindow("tuneplayer")
        self.tuneplayer_open = false
        return
    end

    self.tuneplayer_open = true
    local win = createTunePlayerWindow(self.music_player)
    self.window_manager:addWindow(win)
end

function GameState:countJackpotWindows()
    local count = 0
    for _, win in ipairs(self.window_manager.windows) do
        if win.data and win.data.lead_rarity == "jackpot" then
            count = count + 1
        end
    end
    return count
end

function GameState:closeRandomDecrypterWindow()
    -- Collect decrypter windows (not shop/inbox/manual)
    local decrypter_wins = {}
    for _, win in ipairs(self.window_manager.windows) do
        if win.id ~= "shop" and win.id ~= "inbox" and win.id ~= "manual"
           and win.id ~= "netledger" and win.id ~= "tuneplayer" then
            table.insert(decrypter_wins, win)
        end
    end
    if #decrypter_wins > 0 then
        local victim = decrypter_wins[math.random(#decrypter_wins)]
        self.window_manager:removeWindow(victim.id)
        self.notifications:notify("Trace interference - window lost!")
    end
end

function GameState:update(dt)
    -- Update lead spawning
    local new_lead = self.lead_system:update(dt)
    if new_lead then
        self.notifications:notify("New lead: " .. new_lead.rarity:upper() .. " #" .. new_lead.id)
        self:updateInboxBadge()
    end

    -- Update max leads based on hardware
    self.lead_system:setMaxLeads(self.hardware:getMaxLeads())

    -- Update windows (decrypters auto-advance)
    self.window_manager:update(dt)

    -- Count active decrypter windows and jackpot windows for trace
    local active_count = self.window_manager:getWindowCount()
    if self.shop_open then active_count = active_count - 1 end
    if self.inbox_open then active_count = active_count - 1 end
    if self.manual_open then active_count = active_count - 1 end
    if self.netledger_open then active_count = active_count - 1 end
    if self.tuneplayer_open then active_count = active_count - 1 end
    active_count = math.max(0, active_count)

    local jackpot_count = self:countJackpotWindows()
    self.trace:update(dt, active_count, self.hardware, jackpot_count)

    -- Check trace consequences
    local consequence = self.trace:getConsequences()

    -- 90%+ trace: randomly close windows
    if consequence == "close_windows" and self.trace:shouldCloseWindow() then
        self:closeRandomDecrypterWindow()
    end

    -- Raid at 100%
    if consequence == "raid" and self.raid_cooldown <= 0 then
        local penalty, damaged = self.trace:onRaid(self.economy, self.hardware)
        self.raid_message = string.format("System breach! Lost %d CR%s", penalty,
            damaged and (", " .. damaged:upper() .. " damaged") or "")
        self.raid_cooldown = 5.0

        -- Close all decrypter windows
        local to_remove = {}
        for _, win in ipairs(self.window_manager.windows) do
            if win.id ~= "shop" and win.id ~= "inbox" and win.id ~= "manual"
               and win.id ~= "netledger" and win.id ~= "tuneplayer" then
                table.insert(to_remove, win.id)
            end
        end
        for _, id in ipairs(to_remove) do
            self.window_manager:removeWindow(id)
        end
        self.active_decrypters = {}
    end

    if self.raid_cooldown > 0 then
        self.raid_cooldown = self.raid_cooldown - dt
        if self.raid_cooldown <= 0 then
            self.raid_message = nil
        end
    end

    -- Virus crash stays until dismissed via OK button

    -- Music player (auto-advance tracks)
    self.music_player:update(dt)

    -- Desktop icons + notifications
    self.desktop_manager:update(dt)
    self.notifications:update(dt)
end

function GameState:draw()
    local sw = love.graphics.getWidth()
    local sh = love.graphics.getHeight()

    -- Desktop background with dither pattern (pre-rendered canvas)
    local desktop_canvas = Theme.getDesktopCanvas()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(desktop_canvas)

    -- Menu bar at top (with credits + trace)
    Theme.drawMenuBar(sw, self.economy, self.trace)

    -- Desktop icons (behind windows)
    self.desktop_manager:draw()

    -- Windows
    self.window_manager:draw()

    -- Raid overlay as Mac alert box
    if self.raid_message then
        self:drawAlertOverlay(sw, sh, "!", self.raid_message, "System will recover shortly...")
    end

    -- Virus crash overlay (with OK button)
    if self.crash_message then
        self:drawAlertOverlay(sw, sh, "X", self.crash_message, "Read Manual.txt to learn virus signatures.", true)
    end

    -- Trace flicker effect
    if self.trace:getConsequences() == "flicker" or self.trace:getConsequences() == "close_windows" then
        local alpha = math.sin(love.timer.getTime() * 15) * 0.03
        love.graphics.setColor(0.5, 0.5, 0.5, math.abs(alpha))
        love.graphics.rectangle("fill", 0, 0, sw, sh)
    end

    -- Notifications on top of everything
    self.notifications:draw()
end

function GameState:drawAlertOverlay(sw, sh, icon, message, subtitle, show_ok)
    -- Dim background
    love.graphics.setColor(0.0, 0.0, 0.0, 0.4)
    love.graphics.rectangle("fill", 0, 0, sw, sh)

    -- Alert dialog box
    local box_w = 400
    local box_h = show_ok and 130 or 100
    local box_x = (sw - box_w) / 2
    local box_y = (sh - box_h) / 2

    -- Drop shadow
    love.graphics.setColor(0.0, 0.0, 0.0, 0.3)
    love.graphics.rectangle("fill", box_x + 3, box_y + 3, box_w, box_h)

    -- White box
    love.graphics.setColor(Theme.colors.alert_bg)
    love.graphics.rectangle("fill", box_x, box_y, box_w, box_h)

    -- Double border
    love.graphics.setColor(Theme.colors.window_border)
    love.graphics.rectangle("line", box_x, box_y, box_w, box_h)
    love.graphics.rectangle("line", box_x + 2, box_y + 2, box_w - 4, box_h - 4)

    -- Alert icon
    love.graphics.setColor(Theme.colors.text)
    love.graphics.print(icon, box_x + 20, box_y + 20)

    -- Message text
    love.graphics.print(message, box_x + 45, box_y + 20)

    love.graphics.setColor(Theme.colors.text_disabled)
    love.graphics.print(subtitle, box_x + 45, box_y + 45)

    -- OK button
    if show_ok then
        local btn_w, btn_h = 80, 24
        local btn_x = box_x + (box_w - btn_w) / 2
        local btn_y = box_y + box_h - btn_h - 12
        self._alert_ok_rect = { x = btn_x, y = btn_y, w = btn_w, h = btn_h }

        local mx, my = love.mouse.getPosition()
        local hover = mx >= btn_x and mx <= btn_x + btn_w and my >= btn_y and my <= btn_y + btn_h
        Theme.drawBeveledRect(btn_x, btn_y, btn_w, btn_h,
            hover and Theme.colors.button_hover or Theme.colors.button_face)
        love.graphics.setColor(Theme.colors.text)
        local font = love.graphics.getFont()
        local tw = font:getWidth("OK")
        love.graphics.print("OK", btn_x + (btn_w - tw) / 2, btn_y + 5)
    end
end

function GameState:keypressed(key)
    if key == "s" and love.keyboard.isDown("lctrl", "rctrl", "lgui", "rgui") then
        self:toggleShop()
    end

    if key == "i" and love.keyboard.isDown("lctrl", "rctrl", "lgui", "rgui") then
        self:toggleInbox()
    end

    if key == "m" and love.keyboard.isDown("lctrl", "rctrl", "lgui", "rgui") then
        self:toggleManual()
    end

    if key == "b" and love.keyboard.isDown("lctrl", "rctrl", "lgui", "rgui") then
        self:toggleNetLedger()
    end

    if key == "p" and love.keyboard.isDown("lctrl", "rctrl", "lgui", "rgui") then
        self:toggleTunePlayer()
    end

    if key == "f5" then
        Save.save({
            economy = self.economy,
            hardware = self.hardware,
            trace = self.trace,
            lead_system = self.lead_system,
            manual = self.manual,
            music_player = self.music_player,
        })
        self.notifications:notify("Game saved")
    end
end

function GameState:mousepressed(x, y, button)
    -- Crash dialog blocks everything until OK clicked
    if self.crash_message then
        local r = self._alert_ok_rect
        if r and x >= r.x and x <= r.x + r.w and y >= r.y and y <= r.y + r.h then
            self.crash_message = nil
            self._alert_ok_rect = nil
        end
        return
    end

    -- Ignore clicks on menu bar
    if y <= Theme.MENU_BAR_HEIGHT then
        return
    end

    -- Windows get priority (on top of icons)
    if self.window_manager:mousepressed(x, y, button) then
        -- Check if windows were closed via close button
        if self.shop_open and not self.window_manager:getWindow("shop") then
            self.shop_open = false
        end
        if self.inbox_open and not self.window_manager:getWindow("inbox") then
            self.inbox_open = false
        end
        if self.manual_open and not self.window_manager:getWindow("manual") then
            self.manual_open = false
        end
        if self.netledger_open and not self.window_manager:getWindow("netledger") then
            self.netledger_open = false
        end
        if self.tuneplayer_open and not self.window_manager:getWindow("tuneplayer") then
            self.tuneplayer_open = false
        end
        return
    end

    -- Desktop icons
    if self.desktop_manager:mousepressed(x, y, button) then
        return
    end
end

function GameState:mousereleased(x, y, button)
    self.window_manager:mousereleased(x, y, button)
end

-- ============================================================
-- LOVE CALLBACKS
-- ============================================================

function love.load()
    love.graphics.setBackgroundColor(0.75, 0.75, 0.75)

    -- Monospace font
    local font = love.graphics.newFont(13)
    love.graphics.setFont(font)

    -- CRT shader
    local shader_code = love.filesystem.read("assets/shaders/crt.glsl")
    if shader_code then
        crt_shader = love.graphics.newShader(shader_code)
    end

    -- Canvas for shader
    canvas = love.graphics.newCanvas()

    -- State machine
    state_manager = StateManager.new()
    state_manager:addState("menu", MenuState.new(state_manager))
    state_manager:addState("game", GameState.new(state_manager))
    state_manager:switch("menu")

    math.randomseed(os.time())
end

function love.update(dt)
    time = time + dt
    state_manager:update(dt)
end

function love.draw()
    -- Render to canvas
    love.graphics.setCanvas(canvas)
    love.graphics.clear()
    state_manager:draw()
    love.graphics.setCanvas()

    -- Apply CRT shader
    if crt_shader then
        crt_shader:send("time", time)
        local trace_val = 0
        if state_manager.current_name == "game" and state_manager.current.trace then
            trace_val = state_manager.current.trace:getLevel()
        end
        crt_shader:send("trace_intensity", trace_val)
        love.graphics.setShader(crt_shader)
    end

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(canvas)
    love.graphics.setShader()
end

function love.mousepressed(x, y, button)
    state_manager:mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
    state_manager:mousereleased(x, y, button)
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
    state_manager:keypressed(key)
end
