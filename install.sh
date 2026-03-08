#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OS="$(uname -s)"

echo "=== Solo Leveling Terminal Setup ==="

# Ghostty themes (cross-platform)
GHOSTTY_THEMES_DIR="${HOME}/.config/ghostty/themes"
mkdir -p "$GHOSTTY_THEMES_DIR"
cp "$SCRIPT_DIR/ghostty/themes/"* "$GHOSTTY_THEMES_DIR/"
echo "[+] Ghostty themes installed to $GHOSTTY_THEMES_DIR"

case "$OS" in
  Darwin)
    echo "[*] Detected macOS — installing ZSH theme"

    ZSH_THEMES_DIR="${HOME}/.oh-my-zsh/custom/themes"
    mkdir -p "$ZSH_THEMES_DIR"
    cp "$SCRIPT_DIR/macos/zsh/themes/solo-leveling.zsh-theme" "$ZSH_THEMES_DIR/"
    echo "[+] ZSH theme installed to $ZSH_THEMES_DIR"

    ZSH_AUTOSUGGEST_DIR="${HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
    if [[ ! -d "$ZSH_AUTOSUGGEST_DIR" ]]; then
      echo "[*] Installing zsh-autosuggestions..."
      git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_AUTOSUGGEST_DIR"
      echo "[+] zsh-autosuggestions installed"
    else
      echo "[=] zsh-autosuggestions already installed"
    fi

    echo ""
    echo "Now update your configs:"
    echo ""
    echo '  # ~/.config/ghostty/config'
    echo '  theme = dark:SoloLeveling-ShadowMonarch,light:Catppuccin Latte'
    echo ""
    echo '  # ~/.zshrc'
    echo '  ZSH_THEME="solo-leveling"'
    echo '  plugins=(... zsh-autosuggestions)'
    ;;

  Linux)
    echo "[*] Detected Linux — installing Fish theme + Claude aliases"

    FISH_FUNCTIONS_DIR="${HOME}/.config/fish/functions"
    FISH_CONF_DIR="${HOME}/.config/fish/conf.d"
    mkdir -p "$FISH_FUNCTIONS_DIR" "$FISH_CONF_DIR"

    cp "$SCRIPT_DIR/linux/fish/conf.d/solo-leveling.fish" "$FISH_CONF_DIR/"
    echo "[+] Fish config installed to $FISH_CONF_DIR"

    for f in fish_prompt fish_right_prompt claude claudia; do
      cp "$SCRIPT_DIR/linux/fish/functions/${f}.fish" "$FISH_FUNCTIONS_DIR/"
    done
    echo "[+] Fish functions installed to $FISH_FUNCTIONS_DIR"

    echo ""
    echo "Now update your Ghostty config:"
    echo ""
    echo '  # ~/.config/ghostty/config'
    echo '  theme = dark:SoloLeveling-ShadowMonarch,light:Catppuccin Latte'
    echo ""
    echo "Aliases available:"
    echo "  claude  → plan mode + Opus"
    echo "  claudia → bypass permissions + Opus"
    ;;

  *)
    echo "[!] Unsupported OS: $OS"
    exit 1
    ;;
esac

echo ""
echo "Done! Open a new terminal tab to see the changes."
