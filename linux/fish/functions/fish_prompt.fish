# Solo Leveling Powerline — Fish Prompt (Lean-framed)
# Two-line, p10k-Lean-inspired layout on the Solo Leveling palette:
#
#   ╭─  beren@host  ~/…/proj   develop ✓   25.8.1 ────  ✔  3s  16:32 ─╮
#   ╰─❯
#
# Glyphs require a Nerd Font (FiraCode Nerd Font recommended).
# \uXXXX escapes are used outside quotes — Fish does not expand them inside quotes.

function _sl_visible_width
    # Strip ANSI CSI sequences then count chars
    set -l s (string replace -ar '\x1B\[[0-9;]*m' '' -- $argv[1])
    string length -- "$s"
end

function _sl_format_duration
    # CMD_DURATION is in ms
    set -l ms $argv[1]
    set -l s (math "floor($ms / 1000)")
    if test $s -lt 1
        return
    end
    if test $s -lt 60
        echo {$s}s
    else if test $s -lt 3600
        set -l m (math "floor($s / 60)")
        set -l r (math "$s % 60")
        echo "$m"m" $r"s
    else
        set -l h (math "floor($s / 3600)")
        set -l m (math "floor(($s % 3600) / 60)")
        echo "$h"h" $m"m
    end
end

function _sl_render_left
    set -l icon_tux \uf17c
    set -l icon_folder \uf07b
    set -l icon_branch \ue0a0
    set -l icon_node \ue718
    set -l arrow_full \ue0b0
    set -l arrow_thin \ue0b1
    set -l sym_dirty ✗
    set -l sym_clean ✓
    set -l frame_fg brblack

    # Build "bg|fg|content" entries
    set -l segments
    set -a segments "black|white| $icon_tux "
    set -a segments "brblack|cyan| $USER@"(hostname -s)" "
    set -a segments "black|yellow| $icon_folder "(_sl_short_dir)" "

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

    set -l node_ver (_sl_node_info)
    if test -n "$node_ver"
        set -a segments "black|green| $icon_node $node_ver "
    end

    # Render with full powerline arrow between different bgs and a thin one between same bgs.
    set -l prev_bg ""
    for seg in $segments
        set -l p (string split -m 2 '|' $seg)
        set -l bg $p[1]
        set -l fg $p[2]
        set -l content $p[3]

        if test -n "$prev_bg"
            if test "$prev_bg" = "$bg"
                set_color $frame_fg --background $bg
                printf '%s' $arrow_thin
            else
                set_color $prev_bg --background $bg
                printf '%s' $arrow_full
            end
        end
        set_color $fg --background $bg
        printf '%s' $content
        set prev_bg $bg
    end

    # Closing arrow to terminal bg
    set_color $prev_bg --background normal
    printf '%s' $arrow_full
    set_color normal
end

function _sl_render_right
    set -l last_status $argv[1]
    set -l duration $argv[2]
    set -l frame_fg brblack
    set -l sep │  # │

    set -l parts

    if test $last_status -eq 0
        set -a parts (set_color green)✔(set_color normal)
    else
        set -a parts (set_color red)"✘ $last_status"(set_color normal)
    end

    if test $duration -ge 3000
        set -a parts (set_color yellow)(_sl_format_duration $duration)(set_color normal)
    end

    set -a parts (set_color magenta)(date +%H:%M:%S)(set_color normal)

    set -l first 1
    for p in $parts
        if test $first -eq 1
            set first 0
        else
            set_color $frame_fg
            printf ' %s ' $sep
            set_color normal
        end
        printf '%s' $p
    end
end

function fish_prompt
    set -l last_status $status
    set -l duration $CMD_DURATION

    # Record successful commands to success history
    if test $last_status -eq 0; and test -n "$_sl_last_cmd"
        echo "$_sl_last_cmd" >> "$_SL_SUCCESS_HISTFILE"
    end
    set -g _sl_last_cmd ""

    set -l frame_fg brblack
    set -l dash ─   # ─
    set -l tl ╭─  # ╭─
    set -l tr ─╮  # ─╮
    set -l bl ╰─  # ╰─

    # Build left and right into variables so we can measure widths.
    set -l left (set_color $frame_fg)$tl(set_color normal)(_sl_render_left)
    set -l right (_sl_render_right $last_status $duration)" "(set_color $frame_fg)$tr(set_color normal)

    set -l lw (_sl_visible_width "$left")
    set -l rw (_sl_visible_width "$right")
    set -l cols $COLUMNS
    set -l fw (math "$cols - $lw - $rw")
    if test $fw -lt 1
        set fw 1
    end

    set -l fill (string repeat -n $fw -- $dash)

    # Top line: ╭─ [left]   ─── [right] ─╮
    printf '%s' $left
    set_color $frame_fg
    printf '%s' $fill
    set_color normal
    printf '%s' $right
    echo

    # Bottom line: ╰─❯
    set_color $frame_fg
    printf '%s' $bl
    set_color normal
    if test $last_status -eq 0
        set_color green
    else
        set_color red
    end
    printf '❯ '   # ❯
    set_color normal
end
