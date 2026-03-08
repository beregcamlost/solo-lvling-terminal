# Solo Leveling RPG Status Bar — Fish Prompt
# Uses ANSI color codes to adapt to any Ghostty theme

function fish_prompt
    set -l last_status $status

    # Record successful commands to success history
    if test $last_status -eq 0; and test -n "$_sl_last_cmd"
        echo "$_sl_last_cmd" >> "$_SL_SUCCESS_HISTFILE"
    end
    set -g _sl_last_cmd ""

    # Top line segments
    set -l rank (set_color magenta --bold)"[SSS-RANK]"(set_color normal)" ⚡"
    set -l user_info (set_color cyan)"🗡️  $USER@"(hostname -s)(set_color normal)
    set -l dir_info (set_color yellow)"🏯  "(prompt_pwd)(set_color normal)
    set -l time_info (set_color brblack)"⏱   "(date +%T)(set_color normal)

    # Git segment (hidden outside repos)
    set -l git_info ""
    if git rev-parse --is-inside-work-tree &>/dev/null
        set -l branch (git symbolic-ref --short HEAD 2>/dev/null; or git rev-parse --short HEAD 2>/dev/null)
        if git diff --quiet HEAD &>/dev/null; and git diff --cached --quiet HEAD &>/dev/null
            set git_info " | "(set_color magenta)"⚔️  $branch "(set_color green)"✓"(set_color normal)
        else
            set git_info " | "(set_color magenta)"⚔️  $branch "(set_color red)"✗"(set_color normal)
        end
    end

    # HP bar: green on success, red on failure
    if test $last_status -eq 0
        set -l hp (set_color green)"██████████"(set_color normal)
    else
        set -l hp (set_color red)"██████████"(set_color normal)
    end

    echo (set_color brblack)"╔═"(set_color normal)" $rank | $user_info | $dir_info$git_info | $time_info"
    echo -n (set_color brblack)"╚═"(set_color normal)" [HP $hp] "(set_color magenta --bold)"►"(set_color normal)" "
end
