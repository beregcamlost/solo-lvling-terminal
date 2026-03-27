# Solo Leveling — Smart path shortening
# Keeps first + last 2 components, abbreviates middle with "…"

function _sl_short_dir
    set -l full (string replace -- $HOME '~' $PWD)
    set -l parts (string split '/' $full)

    # 3 or fewer components: show as-is
    if test (count $parts) -le 3
        echo $full
        return
    end

    echo "$parts[1]/…/$parts[-2]/$parts[-1]"
end
