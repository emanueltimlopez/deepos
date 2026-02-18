# DEEP

A retro-styled hacking simulation game built with LÖVE2D. Simulates a classic Mac-style OS where players intercept data leads, decrypt hex code, and avoid detection.

## Gameplay

You are a data scavenger operating in the "Dead Internet." Your job: intercept encrypted data packets, decode the hex, extract valuable credentials, keys, and secrets before the system traces you.

### Features

- **Hex Decryption** - Analyze and decode hex data streams to extract hidden values
- **Hardware Upgrades** - Improve RAM (multitasking), GPU (speed), and Storage (lead capacity)
- **Risk Management** - Balance profit vs. trace detection; get raided and lose everything
- **Virus Detection** - Learn to spot malicious patterns before they execute
- **Retro Aesthetics** - Classic Mac System 7 inspired UI with CRT shader effects

## Installation

### Prerequisites

- [LÖVE2D](https://love2d.org/) 11.x

### Running

```bash
# Clone the repository
git clone https://github.com/yourusername/DEEP.git
cd DEEP

# Run with LÖVE2D
love .
```

### Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Enter` | Boot game (from menu) |
| `Ctrl/Cmd + S` | Open Shop |
| `Ctrl/Cmd + I` | Open Inbox |
| `Ctrl/Cmd + M` | Open Manual |
| `Ctrl/Cmd + B` | Open Bank |
| `Ctrl/Cmd + P` | Open Music Player |
| `F5` | Save game |
| `Escape` | Quit |

## Web Build

Build for browser (itch.io):

```bash
./build_web.sh
```

Test locally:

```bash
node server.js
# Open http://localhost:8888
```

## Project Structure

```
DEEP/
├── main.lua              # Entry point, game states
├── conf.lua              # LÖVE configuration
├── src/
│   ├── ui/               # Window, button, theme components
│   ├── systems/          # Economy, hardware, leads, trace
│   └── audio/            # Audio management
├── assets/               # Fonts, shaders, audio
├── lib/                  # Third-party libraries
└── Docs/                 # Design documents
```

## Documentation

- [Game Design Document](Docs/GDD.md)
- [Game Manual](Docs/GAME_MANUAL.md)

## Development

Built with:
- [LÖVE2D](https://love2d.org/) - 2D game framework
- [love.js](https://github.com/2dengine/love.js) - Web build target

## License

MIT
