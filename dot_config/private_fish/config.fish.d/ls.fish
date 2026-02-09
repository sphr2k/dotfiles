# ls wrapper for eza
function ls --wraps eza
    if git rev-parse --is-inside-work-tree &>/dev/null
        eza --long --group --header --group-directories-first --icons --git $argv
    else
        eza --long --group --header --group-directories-first --icons $argv
    end
end