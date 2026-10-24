# Initialize Rust (skip when already initialized)
[ -f Cargo.toml ] || cargo init

# Use shared global cargo target dir for all projects (idempotent, no TOML parsing)
mkdir -p "$HOME/.cargo" "$HOME/.cache/cargo-target"
CARGO_CONFIG="$HOME/.cargo/config.toml"
if [ ! -f "$CARGO_CONFIG" ]; then
  printf '[build]\ntarget-dir = "%s/.cache/cargo-target"\n' "$HOME" > "$CARGO_CONFIG"
elif ! grep -q 'target-dir' "$CARGO_CONFIG" 2>/dev/null; then
  if grep -q '^\[build\]' "$CARGO_CONFIG"; then
    echo "Note: add target-dir to $CARGO_CONFIG manually (existing [build] section kept untouched)"
  else
    printf '\n[build]\ntarget-dir = "%s/.cache/cargo-target"\n' "$HOME" >> "$CARGO_CONFIG"
  fi
fi

# Install project hygiene checker
cargo install --force cargo-collate

# Install mattpocock/skills user-wide
TARGET="/home/$(whoami)/.pi/agent"
npx -y skills@latest add mattpocock/skills -a pi -s '*' -y -g
if [ -n "$(ls -A "$HOME/.agents/skills" 2>/dev/null)" ]; then
  rm -rf "$TARGET/skills"
fi
mkdir -p "$TARGET/skills"
cp -r "$HOME/.agents/skills/." "$TARGET/skills/"
rm -rf "$HOME/.agents/skills" "$HOME/.agents/.skill-lock.json"
rmdir "$HOME/.agents" 2>/dev/null || true

# Copy template files from coding-template and merge pi
# (AGENTS.md is project-specific: keep existing. Everything else reverts to defaults.)
TEMP_DIR=$(mktemp -d)
git clone https://github.com/loxoron218/coding-template.git "$TEMP_DIR"
[ -f AGENTS.md ] || cp "$TEMP_DIR/AGENTS.md" .
cp "$TEMP_DIR"/clippy.toml "$TEMP_DIR"/CODING_STANDARDS.md "$TEMP_DIR"/LICENSE "$TEMP_DIR"/rustfmt.toml "$TEMP_DIR"/lints.toml .
cp -r "$TEMP_DIR"/.pi/. ./.pi/
rm -rf "$TEMP_DIR"

# Sync lints from lints.toml to Cargo.toml (idempotent, template is authoritative)
awk '
  /^\[lints[\.\]]/ { skip=1; next }
  /^\[/ { skip=0 }
  !skip
' Cargo.toml > Cargo.toml.tmp && mv Cargo.toml.tmp Cargo.toml
sed -i -e :a -e '/^\n*$/{$d;N;ba' -e '}' Cargo.toml
[ -n "$(tail -c1 Cargo.toml)" ] && printf '\n' >> Cargo.toml
cat lints.toml >> Cargo.toml
rm -f lints.toml

# Merge pi files to home (user-wide, no project pi/ left behind — template is authoritative)
PI_AGENT="/home/$(whoami)/.pi/agent"
mkdir -p "$PI_AGENT"
cp -r ./pi/. "$PI_AGENT/"
rm -rf ./pi

# User-wide pi wrapper: lean tool selection for sessions, subcommands untouched (idempotent)
mkdir -p "$HOME/.local/bin"
cat > "$HOME/.local/bin/pi" <<'EOF'
#!/bin/sh
# Subcommands must stay argv[1]; global flags before them break parsing.
case "$1" in
  install|remove|uninstall|update|list|config|auth|mcp|-h|--help|-v|--version)
    exec /usr/bin/pi "$@"
    ;;
  *)
    exec /usr/bin/pi --exclude-tools powershell,grep,find,ls "$@"
    ;;
esac
EOF
chmod +x "$HOME/.local/bin/pi"

# Removes the script file after completion
rm "$0"
