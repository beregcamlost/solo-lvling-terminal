# solo-lvling-terminal

Solo Leveling anime-themed terminal setup — 3 Ghostty color schemes + RPG status bar prompt.

## Themes

| Theme | Vibe |
|-------|------|
| **SoloLeveling-ShadowMonarch** | Deep blacks, electric purples, glowing violet |
| **SoloLeveling-DungeonGate** | Midnight blues, teal portal glow, red danger |
| **SoloLeveling-Arise** | Pure black, vivid neon purple/cyan, max contrast |

## Prompt

Two-line RPG status bar with rank badge, git info, and HP bar:

```
╔═ [SSS-RANK] ⚡ | 🗡️  user@host | 🏯  ~/project | ⚔️  main ✓ | ⏱  12:34:56
╚═ [HP ██████████] ►
```

- HP bar turns **green** on success, **red** on failure
- Git segment auto-hides outside repos
- Colors adapt to whichever Ghostty theme is active

## Platform Support

| Platform | Shell | Prompt | Extras |
|----------|-------|--------|--------|
| **macOS** | ZSH (oh-my-zsh) | `solo-leveling.zsh-theme` | Success-only history, autosuggestions, smart completions |
| **Linux** | Fish | `fish_prompt.fish` | Success-only history, `claude`/`claudia` aliases |

### Claude Code Aliases (Linux/Fish)

| Alias | Command |
|-------|---------|
| `claude` | `claude --model claude-opus-4-6 --permission-mode plan` |
| `claudia` | `claude --model claude-opus-4-6 --permission-mode plan --allow-dangerously-skip-permissions` |

## Requirements

- [Ghostty](https://ghostty.org) terminal
- **macOS**: [oh-my-zsh](https://ohmyz.sh) + [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
- **Linux**: [Fish shell](https://fishshell.com)

## Install

```bash
./install.sh
```

The installer auto-detects your OS and installs the right files.

### Manual Install

**Ghostty themes (all platforms):**
```bash
cp ghostty/themes/* ~/.config/ghostty/themes/
```

**macOS (ZSH):**
```bash
cp macos/zsh/themes/solo-leveling.zsh-theme ~/.oh-my-zsh/custom/themes/
# Set ZSH_THEME="solo-leveling" in ~/.zshrc
```

**Linux (Fish):**
```bash
cp linux/fish/conf.d/solo-leveling.fish ~/.config/fish/conf.d/
cp linux/fish/functions/*.fish ~/.config/fish/functions/
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
