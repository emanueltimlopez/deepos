#!/bin/bash

# Configuration
DIST_DIR="dist"
LOVEJS_REPO="https://github.com/2dengine/love.js.git"
LOVEJS_DIR="love.js_temp"

# Clean up previous build
echo "Cleaning up..."
rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR"

# 1. Package the game into game.love
echo "Packaging game.love..."
# Exclude dist folder, git, and other non-game files
zip -9 -r "$DIST_DIR/game_web.love" . -x "*.git*" -x "$DIST_DIR/*" -x "$LOVEJS_DIR/*" -x "server.js" -x "build_web.sh" -x ".DS_Store"

# 2. Fetch love.js files
if [ ! -d "$LOVEJS_DIR" ]; then
    echo "Cloning love.js repository..."
    git clone --depth 1 "$LOVEJS_REPO" "$LOVEJS_DIR"
else
    echo "love.js repository already exists, updating..."
    cd "$LOVEJS_DIR" && git pull && cd ..
fi

# 3. Copy necessary files to dist
echo "Copying runtime files..."
# Based on 2dengine/love.js structure, usually the files are in src or root.
# Let's assume a standard structure or try to find them.
# The compatibility layer usually needs: game.js (or love.js), game.wasm (or love.wasm), and a loader html/js.

# Copying everything from src/ subdirectory of the repo if it exists, or root if it looks like the distribution.
# Checking typical 2dengine/love.js structure: it has 'src' containing 'love.js' and 'love.wasm', and 'index.html'
# We will copy the contents of src/ to dist/

if [ -d "$LOVEJS_DIR/src" ]; then
    cp -r "$LOVEJS_DIR/src/"* "$DIST_DIR/"
else
    cp -r "$LOVEJS_DIR/"* "$DIST_DIR/"
fi

# Patch player.js to force version 11.5 if missing/empty to fix itch.io path resolution
# This sed command inserts the check after the version assignment
sed -i '' "s/var version = ops.version ||  '11.5';/var version = ops.version || '11.5'; if (version === '') version = '11.5';/" "$DIST_DIR/player.js"

# 4. Apply custom template
echo "Applying custom web template..."
cp web_template.html "$DIST_DIR/index.html"

# Remove the .git dir from dist if it was copied
rm -rf "$DIST_DIR/.git"

# 5. Create itch.io build
echo "Creating itch_build.zip..."
cd "$DIST_DIR" && zip -r ../itch_build.zip . && cd ..

echo "Build complete! Files are in $DIST_DIR"
echo "Itch.io build package: itch_build.zip"
echo "Run 'node server.js' to test."

