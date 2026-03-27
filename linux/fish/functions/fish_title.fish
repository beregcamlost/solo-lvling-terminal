# Solo Leveling — Terminal title

function fish_title
    echo "$USER@"(hostname -s)": "(prompt_pwd)
end
