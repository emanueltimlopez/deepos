local Window = require("src.ui.window")
local Button = require("src.ui.button")
local Theme = require("src.ui.theme")

local function createTunePlayerWindow(music_player)
    local scroll_offset = 0

    local win = Window.new(
        "tuneplayer",
        200, Theme.MENU_BAR_HEIGHT + 50,
        320, 300,
        "TunePlayer",
        -- content draw
        function(w, x, y, ww, hh)
            local font = love.graphics.getFont()
            local fh = font:getHeight()

            -- LCD display background
            local lcd_x = x + 10
            local lcd_y = y + 10
            local lcd_w = ww - 20
            local lcd_h = 50

            love.graphics.setColor(0.08, 0.12, 0.08, 1.0)
            love.graphics.rectangle("fill", lcd_x, lcd_y, lcd_w, lcd_h)
            Theme.drawInsetRect(lcd_x, lcd_y, lcd_w, lcd_h)

            -- LCD text
            local track = music_player:getCurrentTrack()
            local track_count = music_player:getTrackCount()

            if track_count == 0 then
                love.graphics.setColor(0.3, 0.5, 0.3, 1.0)
                love.graphics.print("NO TRACKS FOUND", lcd_x + 8, lcd_y + 8)
                love.graphics.print("Add files to assets/music/", lcd_x + 8, lcd_y + 8 + fh + 2)
            else
                local track_num = string.format("TRACK %02d", music_player.current_index)
                local progress = music_player:getProgress()
                local duration = music_player:getDuration()

                local time_str
                if duration > 0 then
                    local pm = math.floor(progress / 60)
                    local ps = math.floor(progress % 60)
                    local dm = math.floor(duration / 60)
                    local ds = math.floor(duration % 60)
                    time_str = string.format("%02d:%02d / %02d:%02d", pm, ps, dm, ds)
                else
                    time_str = "00:00 / 00:00"
                end

                if music_player:isPlaying() then
                    love.graphics.setColor(0.2, 0.9, 0.2, 1.0)
                else
                    love.graphics.setColor(0.3, 0.5, 0.3, 1.0)
                end
                love.graphics.print(track_num .. "  " .. time_str, lcd_x + 8, lcd_y + 8)

                -- Track name
                local name = track and track.name or "---"
                if #name > 34 then name = name:sub(1, 32) .. ".." end
                love.graphics.print(name, lcd_x + 8, lcd_y + 8 + fh + 2)
            end

            -- Progress bar
            local bar_x = x + 10
            local bar_y = lcd_y + lcd_h + 8
            local bar_w = ww - 20
            local bar_h = 8

            love.graphics.setColor(Theme.colors.progress_bg)
            love.graphics.rectangle("fill", bar_x, bar_y, bar_w, bar_h)
            Theme.drawInsetRect(bar_x, bar_y, bar_w, bar_h)

            local duration = music_player:getDuration()
            if duration > 0 then
                local pct = music_player:getProgress() / duration
                love.graphics.setColor(Theme.colors.progress_fill)
                love.graphics.rectangle("fill", bar_x + 1, bar_y + 1, (bar_w - 2) * pct, bar_h - 2)
            end

            local vol_bar_x = x + 50
            local vol_bar_w = ww - 100
            local vol_bar_h = 12

            love.graphics.setColor(Theme.colors.progress_bg)
            love.graphics.rectangle("fill", vol_bar_x, vol_y, vol_bar_w, vol_bar_h)
            Theme.drawInsetRect(vol_bar_x, vol_y, vol_bar_w, vol_bar_h)

            local vol_pct = music_player:getVolume()
            love.graphics.setColor(Theme.colors.progress_fill)
            love.graphics.rectangle("fill", vol_bar_x + 1, vol_y + 1, (vol_bar_w - 2) * vol_pct, vol_bar_h - 2)

            -- Separator before playlist
            local sep_y = vol_y + vol_bar_h + 10
            love.graphics.setColor(Theme.colors.shadow)
            love.graphics.line(x + 10, sep_y, x + ww - 10, sep_y)

            -- Playlist header
            love.graphics.setColor(Theme.colors.text)
            love.graphics.print("Playlist", x + 10, sep_y + 4)

            -- Playlist entries
            local list_y = sep_y + 4 + fh + 4
            local playlist = music_player:getPlaylist()
            local entry_h = fh + 4
            local max_visible = math.floor((y + hh - list_y - 4) / entry_h)

            for i = 1, math.min(#playlist, max_visible) do
                local idx = i + scroll_offset
                if idx > #playlist then break end
                local track = playlist[idx]
                local ey = list_y + (i - 1) * entry_h

                -- Highlight current track
                if idx == music_player.current_index then
                    love.graphics.setColor(0.85, 0.85, 0.95, 1.0)
                    love.graphics.rectangle("fill", x + 5, ey - 1, ww - 10, entry_h)
                    love.graphics.setColor(Theme.colors.text)
                    love.graphics.print("> ", x + 10, ey)
                elseif i % 2 == 0 then
                    love.graphics.setColor(0.93, 0.93, 0.93, 1.0)
                    love.graphics.rectangle("fill", x + 5, ey - 1, ww - 10, entry_h)
                end

                love.graphics.setColor(Theme.colors.text)
                local name = track.name
                if #name > 32 then name = name:sub(1, 30) .. ".." end
                love.graphics.print(string.format("%02d  %s", idx, name), x + 24, ey)
            end
        end,
        -- content update
        function(w, dt)
            w.buttons = {}
            local track_count = music_player:getTrackCount()

            -- Control buttons row
            local btn_y = 78
            local btn_w = 60
            local btn_h = 24
            local center_x = w.w / 2

            -- Prev
            local prev_btn = Button.new(center_x - btn_w * 1.5 - 10, btn_y, btn_w, btn_h, "|<", function()
                music_player:prevTrack()
            end)
            table.insert(w.buttons, prev_btn)

            -- Play/Stop
            local play_label = music_player:isPlaying() and "Stop" or "Play"
            local play_btn = Button.new(center_x - btn_w / 2, btn_y, btn_w, btn_h, play_label, function()
                if music_player:isPlaying() then
                    music_player:stop()
                else
                    music_player:play()
                end
            end)
            table.insert(w.buttons, play_btn)

            -- Next
            local next_btn = Button.new(center_x + btn_w / 2 + 10, btn_y, btn_w, btn_h, ">|", function()
                music_player:nextTrack()
            end)
            table.insert(w.buttons, next_btn)

            -- Volume -/+ buttons
            local vol_y = 78 + btn_h + 18
            local vol_btn = Button.new(10, vol_y - 2, 28, 18, "-", function()
                music_player:setVolume(music_player:getVolume() - 0.1)
            end)
            table.insert(w.buttons, vol_btn)

            local vol_up_btn = Button.new(w.w - 38, vol_y - 2, 28, 18, "+", function()
                music_player:setVolume(music_player:getVolume() + 0.1)
            end)
            table.insert(w.buttons, vol_up_btn)

            -- Playlist click targets
            local font = love.graphics.getFont()
            local fh = font:getHeight()
            local sep_y = vol_y + 12 + 10
            local list_y = sep_y + 4 + fh + 4
            local entry_h = fh + 4
            local max_visible = math.floor((w.h - (list_y - 0) - 4) / entry_h)

            local playlist = music_player:getPlaylist()
            for i = 1, math.min(#playlist, max_visible) do
                local idx = i + scroll_offset
                if idx > #playlist then break end
                local ey = list_y + (i - 1) * entry_h
                local track_idx = idx
                local btn = Button.new(5, ey - 1, w.w - 10, entry_h, "", function()
                    music_player:playTrack(track_idx)
                end)
                btn.visible = false
                table.insert(w.buttons, btn)
            end
        end
    )

    return win
end

return createTunePlayerWindow
