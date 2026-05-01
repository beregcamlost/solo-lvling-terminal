# Solo Leveling Powerline — ZSH Theme (Lean-framed)
# Two-line, p10k-Lean-inspired layout on the Solo Leveling palette:
#
#   ╭─  beren@host  ~/…/proj   develop ✓   25.8.1 ──────  ✔  3s  16:32 ─╮
#   ╰─❯
#
# Palette indices map to Ghostty Solo Leveling themes:
#   0=#1a1a2e  1=#e63946  2=#06d6a0  3=#f4a261
#   4=#4cc9f0  5=#7b2fbe  6=#4895ef  7=#c8c8e0  8=#2d2d4a

zmodload zsh/datetime 2>/dev/null

# ── Success-Only History ──────────────────────────────────────
# Tracks commands that exit 0 in a separate file.

_SL_SUCCESS_HISTFILE="${HOME}/.zsh_history_success"
[[ -f "$_SL_SUCCESS_HISTFILE" ]] || touch "$_SL_SUCCESS_HISTFILE"

_sl_last_cmd=""
_sl_last_exit=0
_sl_ran_cmd=0
_sl_exec_start=0
_sl_exec_time=0

_sl_preexec() {
  _sl_last_cmd="$1"
  _sl_ran_cmd=1
  _sl_exec_start=$EPOCHREALTIME
}

_sl_precmd() {
  local exit_code=$?
  if [[ $_sl_ran_cmd -eq 1 ]]; then
    _sl_last_exit=$exit_code
    if (( _sl_exec_start > 0 )); then
      _sl_exec_time=$(( EPOCHREALTIME - _sl_exec_start ))
    fi
    if [[ $exit_code -eq 0 && -n "$_sl_last_cmd" ]]; then
      print -r -- "$_sl_last_cmd" >> "$_SL_SUCCESS_HISTFILE"
    fi
  else
    _sl_last_exit=0
    _sl_exec_time=0
  fi
  _sl_last_cmd=""
  _sl_ran_cmd=0
  _sl_exec_start=0
}

autoload -Uz add-zsh-hook
add-zsh-hook preexec _sl_preexec
add-zsh-hook precmd  _sl_precmd

# ── Terminal title ────────────────────────────────────────────

_sl_set_title() { print -Pn "\e]2;%n@%m: %~\a" }
add-zsh-hook precmd _sl_set_title

# ── zsh-autosuggestions ───────────────────────────────────────

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

_sl_short_dir() {
  local full="${PWD/#$HOME/~}"
  local parts=("${(@s:/:)full}")
  if [[ ${#parts} -le 3 ]]; then
    echo "$full"
    return
  fi
  echo "${parts[1]}/…/${parts[-2]}/${parts[-1]}"
}

# ── Git info ──────────────────────────────────────────────────

_sl_git_info() {
  local branch
  branch=$(git symbolic-ref --short HEAD 2>/dev/null) \
    || branch=$(git rev-parse --short HEAD 2>/dev/null)
  [[ -z "$branch" ]] && return
  local mark
  if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
    mark="%F{1}%f"
  else
    mark="%F{2}%f"
  fi
  echo "  $branch $mark"
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

# ── Exec time formatting ──────────────────────────────────────

_sl_format_time() {
  local t=$1
  local s=${t%.*}
  (( s < 1 )) && return
  if (( s < 60 )); then
    echo "${s}s"
  elif (( s < 3600 )); then
    echo "$((s/60))m $((s%60))s"
  else
    echo "$((s/3600))h $((s%3600/60))m $((s%60))s"
  fi
}

# ── Visible width of a prompt-expanded string ─────────────────
# Expands %F/%K/%n/%m/etc, then strips ANSI CSI sequences.

_sl_visible_width() {
  emulate -L zsh
  setopt extended_glob
  local s="${(%)1}"
  s=${s//$'\e'\[[0-9;]##m/}
  echo ${#s}
}

# ── Frame ────────────────────────────────────────────────────
# Box-drawing connectors in muted SL palette index 8.

_SL_FRAME_FG=8
_SL_FRAME_TL='╭─'
_SL_FRAME_TR='─╮'
_SL_FRAME_BL='╰─'
_SL_FRAME_BR='─╯'
_SL_FRAME_DASH='─'

# ── Powerline glyphs ─────────────────────────────────────────
#   left full arrow,   left thin (subsegment),  right full,  right thin

_SL_ARROW_L=$''
_SL_THIN_L=$''

# ── Left segments builder ────────────────────────────────────
# Each segment is "bg|fg|content". Renders with full powerline
# arrows between different bgs and a thin separator between
# same-bg segments. Closing arrow falls back to terminal bg.

_sl_render_left() {
  local -a segs
  segs+=("0|7|  ")
  segs+=("8|6| %n@%m ")
  segs+=("0|3|  $(_sl_short_dir) ")

  local git_raw=$(_sl_git_info)
  [[ -n $git_raw ]] && segs+=("8|4|${git_raw} ")

  local node_ver=$(_sl_node_info)
  [[ -n $node_ver ]] && segs+=("0|2|  ${node_ver} ")

  local prev_bg="" out=""
  local seg bg fg content
  for seg in "${segs[@]}"; do
    bg="${seg%%|*}"
    seg="${seg#*|}"
    fg="${seg%%|*}"
    content="${seg#*|}"
    if [[ -n $prev_bg ]]; then
      if [[ $prev_bg == $bg ]]; then
        out+="%F{${_SL_FRAME_FG}}%K{${bg}}${_SL_THIN_L}%f%k"
      else
        out+="%F{${prev_bg}}%K{${bg}}${_SL_ARROW_L}%f%k"
      fi
    fi
    out+="%F{${fg}}%K{${bg}}${content}%f%k"
    prev_bg=$bg
  done
  # Close to terminal bg
  out+="%F{${prev_bg}}${_SL_ARROW_L}%f"
  echo "$out"
}

# ── Right segments ───────────────────────────────────────────
# status, exec_time (>=3s), current time. Joined by thin │ in fg=8.

_sl_render_right() {
  local -a parts
  if [[ $_sl_last_exit -eq 0 ]]; then
    parts+=("%F{2}✔%f")
  else
    parts+=("%F{1}✘ ${_sl_last_exit}%f")
  fi

  if (( ${_sl_exec_time%.*} >= 3 )); then
    parts+=("%F{3}$(_sl_format_time $_sl_exec_time)%f")
  fi

  parts+=("%F{5}%D{%H:%M:%S}%f")

  local out="" i
  for (( i = 1; i <= ${#parts[@]}; i++ )); do
    (( i > 1 )) && out+=" %F{${_SL_FRAME_FG}}│%f "
    out+="${parts[$i]}"
  done
  echo "$out"
}

# ── Info bar ─────────────────────────────────────────────────
# Renders: ╭─ [left segs]  ─── [right segs] ─╮

_sl_info_bar() {
  local left right
  left="%F{${_SL_FRAME_FG}}${_SL_FRAME_TL}%f$(_sl_render_left)"
  right="$(_sl_render_right) %F{${_SL_FRAME_FG}}${_SL_FRAME_TR}%f"

  local lw=$(_sl_visible_width "$left")
  local rw=$(_sl_visible_width "$right")
  local cols=$COLUMNS
  local fw=$(( cols - lw - rw ))
  (( fw < 1 )) && fw=1

  local fill
  printf -v fill "%${fw}s" ""
  fill="${fill// /${_SL_FRAME_DASH}}"

  print -P "${left}%F{${_SL_FRAME_FG}}${fill}%f${right}"
}

add-zsh-hook precmd _sl_info_bar

# ── Clear screen: keep info bar ──────────────────────────────

_sl_clear_screen() {
  printf '\x1b[2J\x1b[H'
  _sl_info_bar
  zle reset-prompt
}
zle -N clear-screen _sl_clear_screen

clear() {
  printf '\x1b[2J\x1b[H'
  _sl_info_bar
}

# ── Prompt ───────────────────────────────────────────────────
# Bottom-left corner + colored ❯ (green ok / red error). RPROMPT closes the box.

setopt PROMPT_SUBST
PROMPT='%F{8}╰─%f%(?.%F{2}.%F{1})❯%f '
RPROMPT='%F{8}─╯%f'
