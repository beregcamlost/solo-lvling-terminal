# Solo Leveling Powerline — ZSH Theme
# Palette indices map to Ghostty ShadowMonarch theme:
#   0=#1a1a2e  1=#e63946  2=#06d6a0  3=#f4a261
#   4=#4cc9f0  5=#7b2fbe  6=#4895ef  7=#c8c8e0  8=#2d2d4a

# ── Success-Only History ──────────────────────────────────────
# Tracks commands that exit 0 in a separate file.
# preexec saves the command, precmd writes it only if it succeeded.

_SL_SUCCESS_HISTFILE="${HOME}/.zsh_history_success"
[[ -f "$_SL_SUCCESS_HISTFILE" ]] || touch "$_SL_SUCCESS_HISTFILE"
_sl_last_cmd=""
_sl_last_exit=0

_sl_preexec() { _sl_last_cmd="$1"; }
_sl_precmd() {
  _sl_last_exit=$?
  if [[ $_sl_last_exit -eq 0 && -n "$_sl_last_cmd" ]]; then
    print -r -- "$_sl_last_cmd" >> "$_SL_SUCCESS_HISTFILE"
  fi
  _sl_last_cmd=""
}

autoload -Uz add-zsh-hook
add-zsh-hook preexec _sl_preexec
add-zsh-hook precmd  _sl_precmd

# ── Terminal title ────────────────────────────────────────────

_sl_set_title() {
  print -Pn "\e]2;%n@%m: %~\a"
}
add-zsh-hook precmd _sl_set_title

# ── zsh-autosuggestions config ────────────────────────────────
# Custom strategy: search success history first, then regular history

_zsh_autosuggest_strategy_sl_success_history() {
  local prefix="$1"
  local match=$(grep -aF "$prefix" "$_SL_SUCCESS_HISTFILE" 2>/dev/null | grep -a "^${prefix}" | tail -1)
  [[ -n "$match" ]] && typeset -g suggestion="$match"
}

ZSH_AUTOSUGGEST_STRATEGY=(sl_success_history history completion)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8,underline"
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=80
ZSH_AUTOSUGGEST_USE_ASYNC=1

# ── Enhanced Completions ──────────────────────────────────────
# Case-insensitive, partial-word, menu-select with Solo Leveling colors

zstyle ':completion:*' matcher-list \
  'm:{a-zA-Z}={A-Za-z}' \
  'r:|[._-]=* r:|=*' \
  'l:|=* r:|=*'

zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors \
  '=(#b)(*)=0=38;5;5' \
  'ma=48;5;5;38;5;0;1'
zstyle ':completion:*:descriptions' format '%F{5}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{1}-- no matches --%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'

# ── Smart path shortening ─────────────────────────────────────
# Abbreviates middle components, keeps first and last full.

_sl_short_dir() {
  local full="${PWD/#$HOME/~}"
  # If the path has 3 or fewer components, show as-is
  local parts=("${(@s:/:)full}")
  if [[ ${#parts} -le 3 ]]; then
    echo "$full"
    return
  fi
  # Keep first component and last two, abbreviate middle ones
  local first="${parts[1]}"
  local last="${parts[-1]}"
  local second_last="${parts[-2]}"
  echo "${first}/…/${second_last}/${last}"
}

# ── Git info ──────────────────────────────────────────────────

_sl_git_info() {
  local branch
  branch=$(git symbolic-ref --short HEAD 2>/dev/null) \
    || branch=$(git rev-parse --short HEAD 2>/dev/null)
  [[ -z "$branch" ]] && return
  local dirty
  if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
    dirty="%F{1}%f"
  else
    dirty="%F{2}%f"
  fi
  echo "  $branch $dirty"
}

# ── Node info ─────────────────────────────────────────────────

_sl_node_info() {
  local dir="$PWD"
  while [[ "$dir" != "/" ]]; do
    if [[ -f "$dir/package.json" ]]; then
      node -v 2>/dev/null | tr -d 'v'
      return
    fi
    dir="${dir:h}"
  done
}

# ── Powerline segments ────────────────────────────────────────
# Prints the info bar above the prompt via precmd hook.
# Arrow character  (U+E0B0) requires a Nerd Font.
# Apple logo  (U+F179) requires a Nerd Font.

_sl_info_bar() {
  local exit_code=$_sl_last_exit

  # Segment 0: OS icon — white on dark purple (bg=0)
  local seg0="%F{7}%K{0}  %f%k"

  # Arrow 0→1: fg=0 (dark purple), bg=8 (lighter purple)
  local arr01="%F{0}%K{8}%f"

  # Segment 1: user@host — cyan on lighter purple (bg=8)
  local seg1="%F{6}%K{8} %n@%m %f%k"

  # Arrow 1→2: fg=8 (lighter purple), bg=0 (dark purple)
  local arr12="%F{8}%K{0}%f"

  # Segment 2: folder — yellow on dark purple (bg=0)
  local seg2="%F{3}%K{0}  $(_sl_short_dir) %f%k"

  # Git segment (conditional)
  local git_raw
  git_raw=$(_sl_git_info)
  local seg_git=""
  local arr_git=""
  if [[ -n "$git_raw" ]]; then
    # Arrow 2→git: fg=0, bg=8
    arr_git="%F{0}%K{8}%f"
    seg_git="%F{4}%K{8}${git_raw} %f%k"
    # After git the "current bg" is 8
    local after_git_arr="%F{8}%K{0}%f"

    # Node segment (conditional, chained after git)
    local node_ver
    node_ver=$(_sl_node_info)
    local seg_node=""
    if [[ -n "$node_ver" ]]; then
      local arr_node="%F{8}%K{0}%f"  # already at bg=0 after git→node arrow
      seg_node="%F{2}%K{0}  ${node_ver} %f%k"
      local after_node_arr="%F{0}"

      # Error segment (conditional)
      local seg_err=""
      if [[ $exit_code -ne 0 ]]; then
        seg_err="%F{0}%K{1}%f%F{15}%K{1}  %f%k%F{1}%f"
        print -P "${seg0}${arr01}${seg1}${arr12}${seg2}${arr_git}${seg_git}${after_git_arr}${seg_node}${seg_err}"
      else
        print -P "${seg0}${arr01}${seg1}${arr12}${seg2}${arr_git}${seg_git}${after_git_arr}${seg_node}%F{0}%f"
      fi
    else
      # No node
      local seg_err=""
      if [[ $exit_code -ne 0 ]]; then
        seg_err="${after_git_arr}%F{15}%K{1}  %f%k%F{1}%f"
        print -P "${seg0}${arr01}${seg1}${arr12}${seg2}${arr_git}${seg_git}${seg_err}"
      else
        print -P "${seg0}${arr01}${seg1}${arr12}${seg2}${arr_git}${seg_git}${after_git_arr}%f"
      fi
    fi
  else
    # No git — after folder bg=0
    local node_ver
    node_ver=$(_sl_node_info)
    local seg_node=""
    if [[ -n "$node_ver" ]]; then
      # Arrow 2→node: fg=0, bg=0 (same bg, just separator color)
      local arr_node="%F{8}%K{0}%f"
      seg_node="%F{2}%K{0}  ${node_ver} %f%k"

      if [[ $exit_code -ne 0 ]]; then
        local seg_err="%F{0}%K{1}%f%F{15}%K{1}  %f%k%F{1}%f"
        print -P "${seg0}${arr01}${seg1}${arr12}${seg2}${arr_node}${seg_node}${seg_err}"
      else
        print -P "${seg0}${arr01}${seg1}${arr12}${seg2}${arr_node}${seg_node}%F{0}%f"
      fi
    else
      # No git, no node
      if [[ $exit_code -ne 0 ]]; then
        local seg_err="%F{0}%K{1}%f%F{15}%K{1}  %f%k%F{1}%f"
        print -P "${seg0}${arr01}${seg1}${arr12}${seg2}${seg_err}"
      else
        print -P "${seg0}${arr01}${seg1}${arr12}${seg2}%F{0}%f"
      fi
    fi
  fi
}

add-zsh-hook precmd _sl_info_bar

# ── Prompt ────────────────────────────────────────────────────

setopt PROMPT_SUBST
PROMPT='%F{5}❯%f '
RPROMPT='%F{5}%T%f'
