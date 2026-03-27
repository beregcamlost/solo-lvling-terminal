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

    # Nerd Font glyphs (must be unquoted — Fish only expands \uXXXX outside quotes)
    set -l icon_tux \uf17c
    set -l icon_folder \uf07b
    set -l icon_branch \ue0a0
    set -l icon_node \ue718
    set -l icon_warn \uf071
    set -l arrow \ue0b0
    set -l sym_dirty \u2717
    set -l sym_clean \u2713

    # ── Build segment list: "bg|fg|content" ──
    set -l segments

    # OS icon (Tux)
    set -a segments "black|white| $icon_tux "

    # user@host
    set -a segments "brblack|cyan| $USER@"(hostname -s)" "

    # Folder
    set -a segments "black|yellow| $icon_folder "(_sl_short_dir)" "

    # Git (conditional)
    set -l git_data (_sl_git_info)
    if test -n "$git_data"
        set -l parts (string split '|' $git_data)
        set -l branch $parts[1]
        if test "$parts[2]" = 1
            set -l ind (set_color red --background brblack)"$sym_dirty"
            set -a segments "brblack|blue| $icon_branch $branch $ind "
        else
            set -l ind (set_color green --background brblack)"$sym_clean"
            set -a segments "brblack|blue| $icon_branch $branch $ind "
        end
    end

    # Node (conditional)
    set -l node_ver (_sl_node_info)
    if test -n "$node_ver"
        set -a segments "black|green| $icon_node $node_ver "
    end

    # Error (conditional)
    if test $last_status -ne 0
        set -a segments "red|brwhite| $icon_warn "
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
            printf '%s' $arrow
        end
        set_color $fg --background $bg
        printf '%s' $content
        set prev_bg $bg
    end

    # Final closing arrow
    set_color $prev_bg --background normal
    printf '%s' $arrow
    set_color normal
    echo

    # Prompt character
    set_color magenta
    printf '❯ '
    set_color normal
end
