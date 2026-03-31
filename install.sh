#!/usr/bin/env bash
# install.sh — Antigravity Agent Bundle Installer (Linux/macOS)
# Usage: chmod +x install.sh && ./install.sh [/path/to/your-project]
# Default: installs to current directory

set -e

PROJECT_PATH="${1:-$(pwd)}"
BUNDLE_DIR="$(cd "$(dirname "$0")" && pwd)/.agent"
TARGET_DIR="$PROJECT_PATH/.agent"

echo ""
echo "=========================================="
echo "  Antigravity Agent Bundle Installer"
echo "=========================================="
echo ""

# Validate project path
if [ ! -d "$PROJECT_PATH" ]; then
  echo "[ERROR] Project path not found: $PROJECT_PATH"
  exit 1
fi

# Validate bundle source
echo "[1/4] Checking bundle source..."
if [ ! -d "$BUNDLE_DIR" ]; then
  echo "[ERROR] .agent/ folder not found in bundle. Run this script from the bundle root."
  exit 1
fi
echo "      OK - Bundle found at: $BUNDLE_DIR"

# Copy .agent/ to project
echo "[2/4] Copying .agent/ to project..."
if [ -d "$TARGET_DIR" ]; then
  BACKUP="${TARGET_DIR}.backup.$(date +%Y%m%d-%H%M)"
  echo "      Backing up existing .agent/ to $BACKUP"
  cp -r "$TARGET_DIR" "$BACKUP"
fi
cp -r "$BUNDLE_DIR" "$TARGET_DIR"
echo "      OK - Copied to: $TARGET_DIR"

# Create context folder
echo "[3/4] Creating project context folder..."
CONTEXT_DIR="$TARGET_DIR/context"
if [ ! -d "$CONTEXT_DIR" ]; then
  mkdir -p "$CONTEXT_DIR"
  echo "      OK - Created: $CONTEXT_DIR"
else
  echo "      SKIP - Already exists: $CONTEXT_DIR"
fi

# Create ERRORS.md
echo "[4/4] Creating ERRORS.md log file..."
ERRORS_FILE="$PROJECT_PATH/ERRORS.md"
if [ ! -f "$ERRORS_FILE" ]; then
  cat > "$ERRORS_FILE" << 'EOF'
# ERRORS.md — Error Log

> Log errors encountered during development here.
EOF
  echo "      OK - Created: $ERRORS_FILE"
else
  echo "      SKIP - Already exists"
fi

echo ""
echo "=========================================="
echo "  Installation Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "  1. Rename GEMINI.template.md → GEMINI.md (fill in project name)"
echo "  2. Rename START_HERE.template.md → START_HERE.md (fill in tech stack)"
echo "  3. Create context files in .agent/context/ (use /skill project-context-template)"
echo "  4. Open your project in Antigravity IDE"
echo ""
echo "Happy coding! 🚀"
