# Initialize Rust
cargo init

# Install CLI and init
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git
printf "y\nsh\n" | specify init --here --ai opencode

# Copy template files from vibe-code-template and merge .opencode
TEMP_DIR=$(mktemp -d)
git clone https://github.com/loxoron218/vibe-code-template.git "$TEMP_DIR"
cp "$TEMP_DIR"/AGENTS.md "$TEMP_DIR"/clippy.toml "$TEMP_DIR"/LICENSE "$TEMP_DIR"/rustfmt.toml .
cp -r "$TEMP_DIR"/.opencode/. ./.opencode/
rm -rf "$TEMP_DIR"

# Merge opencode files to home 
TARGET="/home/$(whoami)/.config/opencode"
mkdir -p "$TARGET"
cp -r ./.opencode/. "$TARGET"
rm -rf ./.opencode

# Add specify to gitignore
echo ".specify/scripts" >> .gitignore
echo ".specify/templates" >> .gitignore

# Removes the script file after completion
rm "$0"