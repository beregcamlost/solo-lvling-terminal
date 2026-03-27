# solo-lvling-terminal

Solo Leveling anime-themed terminal setup — 3 Ghostty color schemes + powerline prompt for ZSH and Fish.

## Themes

| Theme | Vibe |
|-------|------|
| **SoloLeveling-ShadowMonarch** | Deep blacks, electric purples, glowing violet |
| **SoloLeveling-DungeonGate** | Midnight blues, teal portal glow, red danger |
| **SoloLeveling-Arise** | Pure black, vivid neon purple/cyan, max contrast |

## Prompt

Powerline-style two-line prompt. The info bar is rendered via `precmd`; the input line is a clean `❯`.

```
  beren@Beren-MBP  ~/…/nodejs/project   develop ✓   25.8.1
❯
```

Segments (left to right):

- OS icon () — always shown
- `user@host` — always shown
- Folder () — smart-shortened path
- Git branch + status ( branch  /  ) — hidden outside repos
- Node version () — hidden when not applicable
- Error indicator () — shown only on non-zero exit

Colors adapt to whichever Ghostty theme is active via ANSI color indices. Powerline arrows () separate segments.

Additional features:

- **Persistent info bar** — survives `clear` and Ctrl+L (screen is cleared via ANSI escapes, then the bar redraws)
- **Success-only history** — only exit-0 commands are recorded to a separate history file
- **macOS extras** — `zsh-autosuggestions` strategy using success history, menu-select tab completion with arrow navigation

## Platform Support

| Platform | Shell | Prompt | Extras |
|----------|-------|--------|--------|
| **macOS** | ZSH (oh-my-zsh) | `solo-leveling.zsh-theme` | Success-only history, autosuggestions, smart completions |
| **Linux** | Fish | `fish_prompt.fish` | Powerline info bar, git/node segments, success-only history, `claude`/`claudia`/`claudeteam` aliases |

### Claude Code Aliases (Linux/Fish)

| Alias | Command |
|-------|---------|
| `claude` | `claude --model claude-opus-4-6 --permission-mode plan` |
| `claudia` | `claude --model claude-opus-4-6 --permission-mode plan --allow-dangerously-skip-permissions` |
| `claudeteam` | `claude --model claude-opus-4-6 --permission-mode plan` inside tmux (agent teams) |

## Requirements

- [Ghostty](https://ghostty.org) terminal
- **macOS**: [oh-my-zsh](https://ohmyz.sh) + [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
- **Linux**: [Fish shell](https://fishshell.com)
- A [Nerd Font](https://www.nerdfonts.com) — e.g. **FiraCode Nerd Font** (required for powerline glyphs)

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
# Set font-family = FiraCode Nerd Font in ~/.config/ghostty/config
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
