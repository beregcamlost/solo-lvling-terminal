# Solo Leveling — Git branch + dirty state
# Returns "branch|0" (clean) or "branch|1" (dirty), empty if not in git repo

function _sl_git_info
    set -l branch (git symbolic-ref --short HEAD 2>/dev/null)
    or set branch (git rev-parse --short HEAD 2>/dev/null)
    or return

    if git diff --quiet HEAD 2>/dev/null; and git diff --cached --quiet HEAD 2>/dev/null
        echo "$branch|0"
    else
        echo "$branch|1"
    end
end
