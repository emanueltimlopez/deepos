local Window = require("src.ui.window")
local Button = require("src.ui.button")
local Theme = require("src.ui.theme")

local ROWS_PER_PAGE = 10

local function createNetLedgerWindow(economy)
    local page = 1

    local win = Window.new(
        "netledger",
        80, Theme.MENU_BAR_HEIGHT + 40,
        440, 380,
        "NetLedger",
        -- content draw
        function(w, x, y, ww, hh)
            local font = love.graphics.getFont()
            local fh = font:getHeight()

            -- Header: balance
            love.graphics.setColor(Theme.colors.text)
            love.graphics.print("Current Balance", x + 10, y + 10)

            love.graphics.setColor(Theme.colors.text)
            love.graphics.print(economy:getCredits() .. " CR", x + 10, y + 10 + fh + 2)

            -- Separator
            local sep_y = y + 10 + fh * 2 + 6
            love.graphics.setColor(Theme.colors.shadow)
            love.graphics.line(x + 10, sep_y, x + ww - 10, sep_y)

            -- Column headers
            local header_y = sep_y + 6
            love.graphics.setColor(Theme.colors.text)
            love.graphics.print("Date", x + 10, header_y)
            love.graphics.print("Description", x + 95, header_y)
            love.graphics.print("Amount", x + 280, header_y)
            love.graphics.print("Status", x + 365, header_y)

            -- Another separator
            love.graphics.setColor(Theme.colors.shadow)
            love.graphics.line(x + 10, header_y + fh + 2, x + ww - 10, header_y + fh + 2)

            -- Transaction rows (newest first)
            local txns = economy:getTransactions()
            local total = #txns
            local total_pages = math.max(1, math.ceil(total / ROWS_PER_PAGE))
            if page > total_pages then page = total_pages end

            if total == 0 then
                love.graphics.setColor(Theme.colors.text_disabled)
                love.graphics.print("No transactions yet", x + 10, header_y + fh + 12)
                return
            end

            local row_y = header_y + fh + 8
            local row_h = fh + 6

            -- Calculate which transactions to show (newest first)
            local start_idx = total - (page - 1) * ROWS_PER_PAGE
            local end_idx = math.max(1, start_idx - ROWS_PER_PAGE + 1)

            local row_num = 0
            for i = start_idx, end_idx, -1 do
                local txn = txns[i]
                if not txn then break end

                local ry = row_y + row_num * row_h

                -- Alternating row background
                if row_num % 2 == 1 then
                    love.graphics.setColor(0.93, 0.93, 0.93, 1)
                    love.graphics.rectangle("fill", x + 5, ry - 1, ww - 10, row_h)
                end

                -- Date
                love.graphics.setColor(Theme.colors.text_disabled)
                local date_str = os.date("%m/%d %H:%M", txn.date)
                love.graphics.print(date_str, x + 10, ry)

                -- Description (truncate if too long)
                love.graphics.setColor(Theme.colors.text)
                local desc = txn.description or ""
                if #desc > 22 then desc = desc:sub(1, 20) .. ".." end
                love.graphics.print(desc, x + 95, ry)

                -- Amount with color
                if txn.amount >= 0 then
                    love.graphics.setColor(0.0, 0.5, 0.0, 1.0)
                    love.graphics.print("+" .. txn.amount, x + 280, ry)
                else
                    love.graphics.setColor(0.6, 0.0, 0.0, 1.0)
                    love.graphics.print(tostring(txn.amount), x + 280, ry)
                end

                -- Status
                love.graphics.setColor(Theme.colors.text_disabled)
                love.graphics.print("Cleared", x + 365, ry)

                row_num = row_num + 1
            end

            -- Page indicator
            love.graphics.setColor(Theme.colors.text_disabled)
            love.graphics.print(
                string.format("Page %d / %d", page, total_pages),
                x + 10, y + hh - 28
            )
        end,
        -- content update
        function(w, dt)
            w.buttons = {}
            local txns = economy:getTransactions()
            local total = #txns
            local total_pages = math.max(1, math.ceil(total / ROWS_PER_PAGE))
            if page > total_pages then page = total_pages end

            if page > 1 then
                local btn = Button.new(w.w - 170, w.h - 34, 80, 24, "Newer", function()
                    page = page - 1
                end)
                table.insert(w.buttons, btn)
            end

            if page < total_pages then
                local btn = Button.new(w.w - 85, w.h - 34, 80, 24, "Older", function()
                    page = page + 1
                end)
                table.insert(w.buttons, btn)
            end
        end
    )

    return win
end

return createNetLedgerWindow
