# Solo Leveling RPG Status Bar — ZSH Theme
# Uses ANSI color indices (%F{N}) to adapt to any Ghostty theme

# ── Success-Only History ──────────────────────────────────────
# Tracks commands that exit 0 in a separate file.
# preexec saves the command, precmd writes it only if it succeeded.

_SL_SUCCESS_HISTFILE="${HOME}/.zsh_history_success"
[[ -f "$_SL_SUCCESS_HISTFILE" ]] || touch "$_SL_SUCCESS_HISTFILE"
_sl_last_cmd=""

_sl_preexec() { _sl_last_cmd="$1"; }
_sl_precmd() {
  local exit_code=$?
  if [[ $exit_code -eq 0 && -n "$_sl_last_cmd" ]]; then
    print -r -- "$_sl_last_cmd" >> "$_SL_SUCCESS_HISTFILE"
  fi
  _sl_last_cmd=""
}

autoload -Uz add-zsh-hook
add-zsh-hook preexec _sl_preexec
add-zsh-hook precmd _sl_precmd

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

# ── Git prompt config (oh-my-zsh) ────────────────────────────

ZSH_THEME_GIT_PROMPT_PREFIX="%F{5}%1{⚔️%} "
ZSH_THEME_GIT_PROMPT_SUFFIX="%f"
ZSH_THEME_GIT_PROMPT_DIRTY=" %F{1}%1{✗%}%f"
ZSH_THEME_GIT_PROMPT_CLEAN=" %F{2}%1{✓%}%f"

# Build the git segment (empty when not in a repo)
_sl_git_segment() {
  local git_info="$(git_prompt_info)"
  [[ -n "$git_info" ]] && echo " | ${git_info}"
}

# HP bar: green if last command OK ($1=0), red if failed
_sl_hp_bar() {
  if [[ $1 -eq 0 ]]; then
    echo "%F{2}██████████%f"
  else
    echo "%F{1}██████████%f"
  fi
}

# Top line
_sl_top() {
  local rank="%F{5}%B[SSS-RANK]%b %1{⚡%}%f"
  local user="%F{6}%1{🗡️%} %n@%m%f"
  local dir="%F{3}%1{🏯%} %~%f"
  local time="%F{8}%1{⏱%}  %T%f"
  local git='$(_sl_git_segment)'

  echo "${rank} | ${user} | ${dir}${git} | ${time}"
}

# Prompt
setopt PROMPT_SUBST
PROMPT='%F{8}╔═%f $(_sl_top)
%F{8}╚═%f [HP $(_sl_hp_bar $?)] %F{5}%B►%b%f '
RPROMPT=''
