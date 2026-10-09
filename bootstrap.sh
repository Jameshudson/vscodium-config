#!/usr/bin/env bash
#
# One-liner bootstrap for the VSCodium standard setup (macOS).
#
#   curl -fsSL https://raw.githubusercontent.com/Jameshudson/vscodium-config/main/bootstrap.sh | bash
#
set -euo pipefail

REPO_URL="https://github.com/Jameshudson/vscodium-config.git"
DIR="$HOME/Projects/vscodium-config"

echo "==> VSCodium standard setup"

if [ -d "$DIR/.git" ]; then
  echo "--> Updating existing checkout at $DIR"
  git -C "$DIR" pull --ff-only
else
  echo "--> Cloning into $DIR"
  mkdir -p "$(dirname "$DIR")"
  git clone "$REPO_URL" "$DIR"
fi

exec "$DIR/install.sh"
