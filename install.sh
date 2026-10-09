#!/usr/bin/env bash
#
# Bootstrap a VSCodium setup from this repo on a macOS machine.
# Idempotent: safe to re-run (e.g. after cloning onto a new computer).
#
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
USER_DIR="$HOME/Library/Application Support/VSCodium/User"
APP_PATH="/Applications/VSCodium.app"
APP_CLI="$APP_PATH/Contents/Resources/app/bin/codium"
CODIUM_BIN="${CODIUM:-codium}"

ensure_vscodium() {
  if [ -d "$APP_PATH" ]; then
    echo "  VSCodium found at $APP_PATH"
    return
  fi
  if command -v brew >/dev/null 2>&1; then
    echo "  VSCodium not found - installing via Homebrew..."
    brew install --cask vscodium
  else
    echo "  ! VSCodium is not installed and Homebrew was not found." >&2
    echo "    Install Homebrew (https://brew.sh) and re-run, or download" >&2
    echo "    VSCodium from https://vscodium.com" >&2
    exit 1
  fi
}

resolve_cli() {
  if command -v "$CODIUM_BIN" >/dev/null 2>&1; then
    return
  fi
  if [ -x "$APP_CLI" ]; then
    CODIUM_BIN="$APP_CLI"
  fi
}

link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    local backup="$dst.bak.$(date +%Y%m%d%H%M%S)"
    echo "  backing up existing $(basename "$dst") -> $(basename "$backup")"
    mv "$dst" "$backup"
  fi
  ln -sfn "$src" "$dst"
  echo "  linked $dst"
}

echo "==> Checking for VSCodium"
ensure_vscodium
resolve_cli

echo "==> Linking config into: $USER_DIR"
link "$REPO_DIR/settings.json"    "$USER_DIR/settings.json"
link "$REPO_DIR/keybindings.json" "$USER_DIR/keybindings.json"
link "$REPO_DIR/custom.css"       "$USER_DIR/custom.css"

echo "==> Linking snippets"
shopt -s nullglob
for f in "$REPO_DIR"/snippets/*.json; do
  link "$f" "$USER_DIR/snippets/$(basename "$f")"
done
shopt -u nullglob

echo "==> Installing extensions"
if command -v "$CODIUM_BIN" >/dev/null 2>&1; then
  while IFS= read -r ext; do
    [ -z "$ext" ] && continue
    case "$ext" in \#*) continue ;; esac
    echo "  installing $ext"
    "$CODIUM_BIN" --install-extension "$ext" --force >/dev/null 2>&1 || \
      echo "    ! failed to install $ext"
  done < "$REPO_DIR/extensions.txt"
else
  echo "  ! '$CODIUM_BIN' CLI not found." >&2
  echo "    Open VSCodium, then: Cmd+Shift+P -> \"Shell Command: Install 'codium' command in PATH\"." >&2
fi

cat <<'EOF'

==> Done.

One-time custom CSS activation (per machine, and after every VSCodium update):
  1. Quit VSCodium completely.
  2. Grant yourself write access to the app so the extension can patch it:
       sudo chown -R "$(whoami)" "/Applications/VSCodium.app"
  3. Open VSCodium, run: Cmd+Shift+P -> "Enable Custom CSS and JS".
  4. Reload the window when prompted.

Tip: if VSCodium shows an "installation is corrupt" warning, install
"RimuruChan.vscode-fix-checksums-next" or click "Don't show again".
EOF
