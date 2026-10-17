#!/usr/bin/env bash
# ==============================================================================
# Installer for Hotspot AIC8800 Controller (KDE Plasma 6 Widget + CLI)
# For CachyOS / Arch Linux & KDE Plasma 6
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DEST="$HOME/.local/bin/hotspot"
PLASMOID_ID="org.cachyos.hotspot-aic8800"
PLASMOID_DEST="$HOME/.local/share/plasma/plasmoids/$PLASMOID_ID"

echo "=========================================================="
echo "   Installing Hotspot AIC8800 Widget for KDE Plasma 6     "
echo "=========================================================="

# 1. Check prerequisites on Arch / CachyOS
echo "[1/4] Checking dependencies..."
MISSING_PKGS=()
for pkg in plasma5support qrencode iw; do
    if ! pacman -Q "$pkg" >/dev/null 2>&1; then
        MISSING_PKGS+=("$pkg")
    fi
done

if [ ${#MISSING_PKGS[@]} -gt 0 ]; then
    echo "  -> Paket yang belum terpasang: ${MISSING_PKGS[*]}"
    echo "  -> Menjalankan pacman untuk memasang dependensi..."
    sudo pacman -S --needed --noconfirm "${MISSING_PKGS[@]}"
else
    echo "  ✓ Semua dependensi (plasma5support, qrencode, iw) sudah terpasang."
fi

# 2. Install CLI hotspot script
echo "[2/4] Installing CLI script to $BIN_DEST..."
mkdir -p "$HOME/.local/bin"
cp -f "$SCRIPT_DIR/hotspot" "$BIN_DEST"
chmod +x "$BIN_DEST"

# Ensure ~/.local/bin is in PATH if not already
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo "  ! Catatan: Pastikan ~/.local/bin sudah ada di PATH shell Anda."
fi
echo "  ✓ Script 'hotspot' terpasang di $BIN_DEST"

# 3. Install Plasma Widget
echo "[3/4] Installing Plasmoid to $PLASMOID_DEST..."
rm -rf "$PLASMOID_DEST"
mkdir -p "$PLASMOID_DEST"
cp -f "$SCRIPT_DIR/metadata.json" "$PLASMOID_DEST/"
cp -rf "$SCRIPT_DIR/contents" "$PLASMOID_DEST/"
echo "  ✓ Widget terpasang di $PLASMOID_DEST"

# 4. Refresh Plasma cache
echo "[4/4] Refreshing KDE Plasma widget cache..."
if command -v kbuildsycoca6 >/dev/null 2>&1; then
    kbuildsycoca6 --noincremental >/dev/null 2>&1 || true
fi

echo ""
echo "=========================================================="
echo "✓ Instalasi Selesai!"
echo "=========================================================="
echo "Cara menambahkan ke Panel KDE Plasma:"
echo "1. Klik kanan pada Panel taskbar KDE Plasma Anda."
echo "2. Pilih 'Add or Manage Widgets...' (Tambah Widget...)."
echo "3. Cari 'Hotspot AIC8800'."
echo "4. Drag / seret widget tersebut ke panel Anda."
echo ""
echo "Jika widget belum muncul di daftar pencarian, restart plasmashell:"
echo "  systemctl --user restart plasma-plasmashell"
echo "=========================================================="
