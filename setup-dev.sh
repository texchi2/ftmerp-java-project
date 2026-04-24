#!/bin/bash
# FTM dev environment setup — run once after cloning framework
set -e

FRAMEWORK_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGINS_REPO="git@github.com:texchi2/ftmerp-java-plugins.git"
PLUGINS_DIR="$(dirname "$FRAMEWORK_DIR")/ofbiz-plugins"
PLUGINS_BRANCH="${1:-feature/ftm-garments}"

echo "=== FTM Dev Environment Setup ==="

# 1. Clone plugins if not present
if [ ! -d "$PLUGINS_DIR" ]; then
  echo "[1/4] Cloning plugins repo..."
  git clone -b "$PLUGINS_BRANCH" "$PLUGINS_REPO" "$PLUGINS_DIR"
else
  echo "[1/4] Plugins repo already exists at $PLUGINS_DIR"
  git -C "$PLUGINS_DIR" checkout "$PLUGINS_BRANCH"
  git -C "$PLUGINS_DIR" pull --rebase
fi

# 2. Create symlink
if [ ! -L "$FRAMEWORK_DIR/plugins" ]; then
  echo "[2/4] Creating plugins symlink..."
  ln -s "$PLUGINS_DIR" "$FRAMEWORK_DIR/plugins"
else
  echo "[2/4] Symlink already exists"
fi

# 3. Restore entityengine.xml passwords
echo "[3/4] Checking entityengine.xml..."
if grep -q "YOUR_FTMUSER_PASSWORD" \
    "$FRAMEWORK_DIR/framework/entity/config/entityengine.xml"; then
  echo "  WARNING: Restore passwords from gradle.properties.local"
  echo "  Run: bash docs/restore-passwords.sh"
else
  echo "  Passwords already set"
fi

# 4. Protect entityengine.xml from accidental commit
git -C "$FRAMEWORK_DIR" update-index --assume-unchanged \
  framework/entity/config/entityengine.xml 2>/dev/null || true
echo "[4/4] entityengine.xml protected (assume-unchanged)"

echo ""
echo "=== Setup complete ==="
echo "Run: bash start-ftm.sh"
