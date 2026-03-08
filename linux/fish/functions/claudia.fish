# Claude Code — plan mode + bypass permissions with Opus (YOLO mode)
function claudia
    command claude --model claude-opus-4-6 --permission-mode plan --allow-dangerously-skip-permissions $argv
end
