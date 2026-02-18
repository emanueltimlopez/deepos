# AGENTS.md

Guidelines for coding agents working in the DEEP codebase.

## Project Overview

DEEP is a retro-styled hacking simulation game built with LÖVE2D (love2d) framework in Lua. The game simulates a classic Mac-style OS where players decrypt hex data leads, manage hardware upgrades, and avoid detection.

**Tech Stack:**
- LÖVE2D 11.x (Lua game framework)
- Lua 5.1/LuaJIT
- Custom UI system with classic Mac aesthetics
- Web build target via love.js

---

## Build/Lint/Test Commands

### Running the Game
```bash
# Run locally with LÖVE2D
love .

# Or from the project root:
love /path/to/DEEP
```

### Web Build
```bash
# Build for web (itch.io)
./build_web.sh

# Test web build locally
node server.js
# Opens at http://localhost:8888
```

### Testing
This project does not currently have an automated test suite. Manual testing is performed by running the game.

### Linting
No linting tool is configured. Follow the code style guidelines below.

---

## Code Style Guidelines

### File Organization
```
DEEP/
├── main.lua              # Entry point, game states, LÖVE callbacks
├── conf.lua              # LÖVE configuration
├── src/
│   ├── ui/               # UI components (windows, buttons, themes)
│   ├── systems/          # Game systems (economy, hardware, leads)
│   └── audio/            # Audio management
├── assets/               # Fonts, shaders, audio files
├── lib/                  # Third-party libraries (json.lua)
└── Docs/                 # Game design documents
```

### Imports

Use `require()` with dotted paths from project root:
```lua
local WindowManager = require("src.ui.window_manager")
local Economy = require("src.systems.economy")
local Theme = require("src.ui.theme")
```

Place all imports at the top of the file before any code.

### Module Pattern

Use the classic Lua module pattern with a factory function:
```lua
local MyModule = {}
MyModule.__index = MyModule

function MyModule.new(arg)
    local self = setmetatable({}, MyModule)
    self.field = arg
    return self
end

function MyModule:method()
    -- use self.field
end

return MyModule
```

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Modules | PascalCase | `WindowManager`, `HexDecrypter` |
| Functions | camelCase | `getMaxLeads()`, `updateInboxBadge()` |
| Methods | camelCase | `self:drawContent()` |
| Variables | snake_case | `active_count`, `lead_system` |
| Constants | SCREAMING_SNAKE | `MAX_TRANSACTIONS`, `TITLE_BAR_HEIGHT` |
| Private fields | underscore prefix | `self._alert_ok_rect` |
| File names | snake_case | `hex_decrypter.lua`, `window_manager.lua` |

### Formatting

- Indent with 4 spaces (no tabs)
- Keep lines under 100 characters when practical
- One statement per line
- No trailing whitespace
- Use blank lines to separate logical sections

```lua
function GameState:update(dt)
    self.lead_system:update(dt)
    
    if new_lead then
        self.notifications:notify("New lead detected")
        self:updateInboxBadge()
    end
end
```

### Types and Data Structures

Lua is dynamically typed. Document expected types in comments when helpful:

```lua
-- @param lead table: { id, rarity, hex_data, is_virus, ... }
function GameState:openDecrypterWindow(lead)
```

For serialization, use simple tables:
```lua
function Economy:serialize()
    return {
        credits = self.credits,
        transactions = self.transactions,
    }
end
```

### Error Handling

Prefer graceful degradation over crashes:
```lua
-- Check conditions before acting
if not self.economy:canAfford(cost) then
    self.notifications:notify("Not enough credits")
    return
end
```

Return early from functions to reduce nesting.

### LÖVE2D Callbacks

Main callbacks live in `main.lua`:
- `love.load()` - Initialize game state
- `love.update(dt)` - Game logic, pass dt to subsystems
- `love.draw()` - Render, delegate to state manager
- `love.keypressed(key)` - Keyboard input
- `love.mousepressed/mousereleased` - Mouse input

### UI Components

UI components follow a consistent pattern:
1. Constructor takes position, size, and callbacks
2. `update(dt)` handles state and hover
3. `draw()` renders using Theme colors
4. Return the module table at end

Window content is passed as draw/update functions:
```lua
Window.new(id, x, y, w, h, title,
    function(w, x, y, ww, hh)  -- draw function
        -- render content
    end,
    function(w, dt)             -- update function
        -- handle buttons, state
    end
)
```

### Color and Theme

Use `Theme.colors` table for consistent styling:
- `Theme.colors.text` - Primary text
- `Theme.colors.text_disabled` - Muted text
- `Theme.colors.window_bg` - Window background
- `Theme.colors.window_border` - Borders
- `Theme.colors.button_face` - Button normal
- `Theme.colors.button_hover` - Button hover

### Comments

- No comments in code unless explicitly asked
- Self-documenting code preferred
- Use section headers for large files:
```lua
-- ============================================================
-- SECTION NAME
-- ============================================================
```

### Serialization

The save system uses JSON via `lib/json.lua`. All serializable modules must implement:
- `serialize()` - Returns simple table
- `deserialize(data)` - Restores from table

---

## Key Architecture Points

1. **State Machine**: `StateManager` handles menu/game state transitions
2. **Window Manager**: Draggable windows with z-ordering and close buttons
3. **Event Flow**: LÖVE callbacks → StateManager → current state → subsystems
4. **Desktop Metaphor**: Icons, notifications, menu bar simulate an OS

---

## Common Tasks

**Add a new window type:**
1. Create module in `src/ui/` following window pattern
2. Add factory function that returns a Window instance
3. Add toggle function in GameState if needed

**Add a new game system:**
1. Create module in `src/systems/`
2. Implement `new()`, `update(dt)`, `serialize()`, `deserialize()`
3. Initialize in `GameState.new()`
4. Add to save/load in `GameState:keypressed("f5")`

**Add keyboard shortcut:**
Add handler in `GameState:keypressed()` using modifier check:
```lua
if key == "x" and love.keyboard.isDown("lctrl", "rctrl", "lgui", "rgui") then
    -- handle Ctrl/Cmd+X
end
```
