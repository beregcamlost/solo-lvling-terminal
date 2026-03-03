# solo-lvling-terminal

Solo Leveling anime-themed terminal setup — 3 Ghostty color schemes + RPG status bar ZSH prompt.

## Themes

| Theme | Vibe |
|-------|------|
| **SoloLeveling-ShadowMonarch** | Deep blacks, electric purples, glowing violet |
| **SoloLeveling-DungeonGate** | Midnight blues, teal portal glow, red danger |
| **SoloLeveling-Arise** | Pure black, vivid neon purple/cyan, max contrast |

## ZSH Prompt

Two-line RPG status bar with rank badge, git info, and HP bar:

```
╔═ [SSS-RANK] ⚡ | 🗡️  user@host | 🏯  ~/project | ⚔️  main ✓ | ⏱  12:34:56
╚═ [HP ██████████] ►
```

- HP bar turns **green** on success, **red** on failure
- Git segment auto-hides outside repos
- Uses `%F{N}` ANSI indices — colors adapt to whichever Ghostty theme is active
- **Smart completions**: success-only history suggestions via zsh-autosuggestions custom strategy, case-insensitive tab completion with menu selection

## Requirements

- [Ghostty](https://ghostty.org) terminal
- [oh-my-zsh](https://ohmyz.sh)
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) plugin

## Install

```bash
./install.sh
```

Or manually:

```bash
# Ghostty themes
cp ghostty/themes/* ~/.config/ghostty/themes/

# ZSH theme
cp zsh/themes/solo-leveling.zsh-theme ~/.oh-my-zsh/custom/themes/

# Set theme in ~/.config/ghostty/config
# theme = dark:SoloLeveling-ShadowMonarch,light:Catppuccin Latte

# Set theme in ~/.zshrc
# ZSH_THEME="solo-leveling"
```

## Switching Themes

Edit `~/.config/ghostty/config`:

```
theme = dark:SoloLeveling-ShadowMonarch,light:Catppuccin Latte
theme = dark:SoloLeveling-DungeonGate,light:Catppuccin Latte
theme = dark:SoloLeveling-Arise,light:Catppuccin Latte
```

Open a new tab to see the change.

## License

MIT
