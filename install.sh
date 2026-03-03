#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Solo Leveling Terminal Setup ==="

# Ghostty themes
GHOSTTY_THEMES_DIR="${HOME}/.config/ghostty/themes"
mkdir -p "$GHOSTTY_THEMES_DIR"
cp "$SCRIPT_DIR/ghostty/themes/"* "$GHOSTTY_THEMES_DIR/"
echo "[+] Ghostty themes installed to $GHOSTTY_THEMES_DIR"

# ZSH theme
ZSH_THEMES_DIR="${HOME}/.oh-my-zsh/custom/themes"
mkdir -p "$ZSH_THEMES_DIR"
cp "$SCRIPT_DIR/zsh/themes/solo-leveling.zsh-theme" "$ZSH_THEMES_DIR/"
echo "[+] ZSH theme installed to $ZSH_THEMES_DIR"

# zsh-autosuggestions
ZSH_AUTOSUGGEST_DIR="${HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
if [[ ! -d "$ZSH_AUTOSUGGEST_DIR" ]]; then
  echo "[*] Installing zsh-autosuggestions..."
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_AUTOSUGGEST_DIR"
  echo "[+] zsh-autosuggestions installed"
else
  echo "[=] zsh-autosuggestions already installed"
fi

echo ""
echo "Done! Now update your configs:"
echo ""
echo '  # ~/.config/ghostty/config'
echo '  theme = dark:SoloLeveling-ShadowMonarch,light:Catppuccin Latte'
echo ""
echo '  # ~/.zshrc'
echo '  ZSH_THEME="solo-leveling"'
echo '  plugins=(... zsh-autosuggestions)'
echo ""
echo "Open a new terminal tab to see the changes."
