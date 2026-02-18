# DEEP

A retro-styled hacking simulation game built with LÖVE2D. Simulates a classic Mac-style OS where players intercept data leads, decrypt hex code, and avoid detection.

## Gameplay

You are a data scavenger operating in the "Dead Internet." Your job: intercept encrypted data packets, decode the hex, extract valuable credentials, keys, and secrets before the system traces you.

## Installation

### Prerequisites

- [LÖVE2D](https://love2d.org/) 11.x

### Running

```bash
# Clone the repository
git clone https://github.com/emanueltimlopez/deepos.git
cd deepos

# Run with LÖVE2D
love .
```

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
```

## Development

Built with:
- [LÖVE2D](https://love2d.org/) - 2D game framework
- [love.js](https://github.com/2dengine/love.js) - Web build target

