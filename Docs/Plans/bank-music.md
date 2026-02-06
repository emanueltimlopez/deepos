# Plan: NetLedger (Banking) + TunePlayer (Music) Apps

## Context
The Interfaz research doc defines two new desktop apps for Sygnal OS. Currently the game has 3 apps (Inbox, Shop, Manual). We're adding:
1. **NetLedger** - Read-only transaction ledger (Quicken 90s style)
2. **TunePlayer** - Music player with real audio playback (CD Player style)

## 1. NetLedger (Banking) - Transaction Log

### 1a. Add transaction logging to Economy (`src/systems/economy.lua`)
- Add `self.transactions = {}` table
- Modify `addCredits(n, description)` and `spendCredits(n, description)` to log entries
- Each entry: `{ date = os.time(), description = "...", amount = +/-n, balance = self.credits }`
- Add `getTransactions()` getter
- Update `serialize()`/`deserialize()` to include transactions (keep last 50)

### 1b. Create NetLedger window (`src/ui/netledger_window.lua`)
- Factory function pattern (like `inbox_window.lua`)
- `createNetLedgerWindow(economy)` → returns Window
- Window ID: `"netledger"`, size ~440x380
- **UI Layout:**
  - Header: "Current Balance" in bold + credits amount
  - Separator line
  - Column headers: Date | Description | Amount | Status
  - Scrollable transaction list (newest first)
  - Amount in green (+) or red (-) via color
  - "Status" column: all show "Cleared" (decorative)
  - Prev/Next page buttons if >10 transactions visible

### 1c. Wire into GameState (`main.lua`)
- Add `self.netledger_open = false` flag
- Add `toggleNetLedger()` method (same pattern as toggleShop)
- Add desktop icon at `sw - 45, Theme.MENU_BAR_HEIGHT + 320`, label "Bank"
- Add close-button cleanup check in `mousepressed`
- Add keyboard shortcut `Ctrl+B`
- Exclude from trace active_count (like shop/inbox/manual)
- Exclude from raid window closing
- Update `addCredits`/`spendCredits` calls throughout main.lua to include descriptions

## 2. TunePlayer (Music)

### 2a. Create music player system (`src/systems/music_player.lua`)
- Scans `assets/music/` for `.ogg`, `.mp3`, `.wav` files on init
- Manages playlist, current track index, playback state
- Uses Love2D `love.audio.newSource(path, "stream")` for music
- Methods: `play()`, `stop()`, `nextTrack()`, `prevTrack()`, `setVolume(v)`, `getVolume()`, `isPlaying()`, `getCurrentTrack()`, `getPlaylist()`, `getProgress()`, `getDuration()`
- Music persists when window is closed (system stays alive)
- `serialize()`/`deserialize()`: save volume, current track index, playing state

### 2b. Create TunePlayer window (`src/ui/tuneplayer_window.lua`)
- Factory function: `createTunePlayerWindow(music_player)` → Window
- Window ID: `"tuneplayer"`, size ~320x300
- **UI Layout:**
  - LCD display: dark rect with green/gray text showing "TRACK 01: 00:45" and track filename
  - Progress bar (visual, not interactive)
  - Control buttons row: [Prev] [Play/Stop] [Next]
  - Volume slider (horizontal bar with clickable regions: -, bar, +)
  - Playlist below: clickable track names, highlight current

### 2c. Wire into GameState (`main.lua`)
- Add `self.music_player = MusicPlayer.new()` in constructor
- Add `self.tuneplayer_open = false` flag
- Add `toggleTunePlayer()` method
- Add desktop icon at `sw - 45, Theme.MENU_BAR_HEIGHT + 410`, label "Music"
- Add close-button cleanup check in `mousepressed`
- Add keyboard shortcut `Ctrl+P` (play)
- Exclude from trace active_count
- Exclude from raid window closing
- Add to save/load serialization

## Files to Create
- `src/ui/netledger_window.lua`
- `src/ui/tuneplayer_window.lua`
- `src/systems/music_player.lua`

## Files to Modify
- `src/systems/economy.lua` (add transaction logging)
- `main.lua` (wire both apps: icons, toggles, shortcuts, save/load, trace exclusion, raid exclusion)

## Verification
- Run `love .` from project root
- Check both desktop icons appear (Bank, Music)
- Click Bank icon → NetLedger window opens showing balance + empty transaction log
- Buy something in Shop → reopen Bank → transaction appears
- Extract a lead → transaction appears
- Click Music icon → TunePlayer window opens
- Add .ogg files to `assets/music/` → tracks appear in playlist, playback works
- Close TunePlayer window → music keeps playing
- Ctrl+B / Ctrl+P shortcuts work
- F5 save → reload → transactions + music state persist
- Trace does NOT increase from Bank/Music windows
- Raid does NOT close Bank/Music windows
