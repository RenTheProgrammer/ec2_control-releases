#!/bin/bash
set -e

APP_NAME="ec2_control"
INSTALL_DIR="$HOME/.local/share/$APP_NAME"
BIN_DIR="$HOME/.local/bin"
DESKTOP_DIR="$HOME/.local/share/applications"
ICON_REL="data/flutter_assets/assets/images/app_icon.jpg"

echo "══════════════════════════════════════"
echo "  EC2 Control — Linux Installer"
echo "══════════════════════════════════════"
echo ""

# Find the tar.gz in the current directory (prefer linux bundle, fall back to arch)
ARCHIVE=$(ls -1 ec2_control-linux-x64.tar.gz 2>/dev/null | head -1)
ARCH_ARCHIVE=""
if [ -z "$ARCHIVE" ]; then
  ARCHIVE=$(ls -1 ec2_control-arch-x64.tar.gz 2>/dev/null | head -1)
  if [ -n "$ARCHIVE" ]; then
    ARCH_ARCHIVE=1
  fi
fi

if [ -z "$ARCHIVE" ]; then
  echo "❌ No ec2_control-{linux,arch}-x64.tar.gz found in the current directory."
  echo "   Download it from: https://github.com/RenTheProgrammer/ec2_control-releases/releases"
  exit 1
fi

echo "📦 Archive: $ARCHIVE"
echo "📂 Install to: $INSTALL_DIR"
echo ""

# Create directories
mkdir -p "$INSTALL_DIR" "$BIN_DIR" "$DESKTOP_DIR"

# Extract
echo "→ Extracting..."
if [ -n "$ARCH_ARCHIVE" ]; then
  # Arch archive stores the bundle under usr/lib/ec2_control/
  TMPDIR=$(mktemp -d)
  tar xzf "$ARCHIVE" -C "$TMPDIR"
  cp -r "$TMPDIR/usr/lib/$APP_NAME/"* "$INSTALL_DIR/"
  rm -rf "$TMPDIR"
else
  # Ubuntu archive is a flat bundle
  tar xzf "$ARCHIVE" -C "$INSTALL_DIR"
fi
echo "  ✓ Extracted to $INSTALL_DIR"

# Make executable
chmod +x "$INSTALL_DIR/$APP_NAME"

# Create symlink in PATH
ln -sf "$INSTALL_DIR/$APP_NAME" "$BIN_DIR/$APP_NAME"
echo "  ✓ Symlinked $BIN_DIR/$APP_NAME"

# Create .desktop file
cat > "$DESKTOP_DIR/$APP_NAME.desktop" << EOF
[Desktop Entry]
Name=EC2 Control
Comment=AWS EC2 Instance Manager
Exec=$INSTALL_DIR/$APP_NAME
Icon=$INSTALL_DIR/$ICON_REL
Type=Application
Categories=Utility;Development;
StartupWMClass=ec2_control
EOF
echo "  ✓ Created desktop entry"

# Update desktop database
if command -v update-desktop-database &>/dev/null; then
  update-desktop-database "$DESKTOP_DIR" 2>/dev/null || true
fi

echo ""
echo "══════════════════════════════════════"
echo "  ✅ Installed successfully!"
echo "══════════════════════════════════════"
echo ""
echo "  Launch from your app menu or run:"
echo "    $APP_NAME"
echo ""
echo "  To uninstall:"
echo "    rm -rf $INSTALL_DIR"
echo "    rm -f $BIN_DIR/$APP_NAME"
echo "    rm -f $DESKTOP_DIR/$APP_NAME.desktop"
echo ""
