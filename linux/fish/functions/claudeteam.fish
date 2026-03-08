# Claude Code — agent teams in tmux (split panes)
function claudeteam
    if set -q TMUX
        command claude --model claude-opus-4-6 --permission-mode plan $argv
    else
        tmux new-session "claude --model claude-opus-4-6 --permission-mode plan $argv"
    end
end
