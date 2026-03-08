# Solo Leveling Terminal — Fish Configuration
# Event handlers and success-only history tracking

set -g _SL_SUCCESS_HISTFILE "$HOME/.fish_history_success"
if not test -f "$_SL_SUCCESS_HISTFILE"
    touch "$_SL_SUCCESS_HISTFILE"
end

set -g _sl_last_cmd ""

function _sl_record_cmd --on-event fish_preexec
    set -g _sl_last_cmd $argv[1]
end
