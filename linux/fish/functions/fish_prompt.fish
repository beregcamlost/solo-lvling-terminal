# Solo Leveling Powerline — Fish Prompt
# Segment builder pattern: flat list rendered with arrow transitions
# Arrow character  (U+E0B0) requires a Nerd Font

function fish_prompt
    set -l last_status $status

    # Record successful commands to success history
    if test $last_status -eq 0; and test -n "$_sl_last_cmd"
        echo "$_sl_last_cmd" >> "$_SL_SUCCESS_HISTFILE"
    end
    set -g _sl_last_cmd ""

    # ── Build segment list: "bg|fg|content" ──
    set -l segments
    set -l arrow \ue0b0

    # OS icon (Tux)
    set -a segments "black|white| \uf17c "

    # user@host
    set -a segments "brblack|cyan| $USER@"(hostname -s)" "

    # Folder
    set -a segments "black|yellow| \uf07b "(_sl_short_dir)" "

    # Git (conditional)
    set -l git_data (_sl_git_info)
    if test -n "$git_data"
        set -l parts (string split '|' $git_data)
        set -l branch $parts[1]
        if test "$parts[2]" = 1
            set -l ind (set_color red --background brblack)"\u2717"
            set -a segments "brblack|blue| \ue0a0 $branch $ind "
        else
            set -l ind (set_color green --background brblack)"\u2713"
            set -a segments "brblack|blue| \ue0a0 $branch $ind "
        end
    end

    # Node (conditional)
    set -l node_ver (_sl_node_info)
    if test -n "$node_ver"
        set -a segments "black|green| \ue718 $node_ver "
    end

    # Error (conditional)
    if test $last_status -ne 0
        set -a segments "red|brwhite| \uf071 "
    end

    # ── Render segments with powerline arrows ──
    set -l prev_bg ""
    for seg in $segments
        set -l p (string split -m 2 '|' $seg)
        set -l bg $p[1]
        set -l fg $p[2]
        set -l content $p[3]

        if test -n "$prev_bg"
            set_color $prev_bg --background $bg
            printf $arrow
        end
        set_color $fg --background $bg
        printf '%s' $content
        set prev_bg $bg
    end

    # Final closing arrow
    set_color $prev_bg --background normal
    printf $arrow
    set_color normal
    echo

    # Prompt character
    set_color magenta
    printf '❯ '
    set_color normal
end
