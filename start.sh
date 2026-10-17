# Initialize Rust (skip when already initialized)
[ -f Cargo.toml ] || cargo init

# Install mattpocock/skills for opencode
npx -y skills@latest add mattpocock/skills -a opencode -s '*' -y

# Copy template files from coding-template and merge .opencode
# (AGENTS.md is project-specific: keep existing. Everything else reverts to defaults.)
TEMP_DIR=$(mktemp -d)
git clone https://github.com/loxoron218/coding-template.git "$TEMP_DIR"
[ -f AGENTS.md ] || cp "$TEMP_DIR/AGENTS.md" .
cp "$TEMP_DIR"/clippy.toml "$TEMP_DIR"/CODING_STANDARDS.md "$TEMP_DIR"/LICENSE "$TEMP_DIR"/rustfmt.toml "$TEMP_DIR"/lints.toml .
cp -r "$TEMP_DIR"/.opencode/. ./.opencode/
rm -rf "$TEMP_DIR"

# Add lints from lints.toml to Cargo.toml (skip when already present)
grep -q '^\[lints' Cargo.toml 2>/dev/null || cat lints.toml >> Cargo.toml
rm -f lints.toml

# Merge opencode files to home
TARGET="/home/$(whoami)/.config/opencode"
mkdir -p "$TARGET"
cp -r ./.opencode/. "$TARGET"
rm -rf ./.opencode

# Removes the script file after completion
rm "$0"
