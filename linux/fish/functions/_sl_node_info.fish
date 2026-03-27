# Solo Leveling — Node version detection
# Walks up from $PWD looking for package.json, returns version or empty

function _sl_node_info
    set -l dir $PWD
    while test "$dir" != /
        if test -f "$dir/package.json"
            node -v 2>/dev/null | string replace 'v' ''
            return
        end
        set dir (path dirname $dir)
    end
end
