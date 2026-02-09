function read_confirm --description "Prompt [y/N], return 0 for yes, 1 for no"
    set -l prompt_msg
    if test (count $argv) -gt 0
        set prompt_msg "$argv[1]"
    else
        set prompt_msg "Proceed?"
    end

    while true
        read -l -P "$prompt_msg [y/N] " confirm
        switch $confirm
            case Y y yes YES Yes
                return 0
            case '' N n no NO No
                return 1
            case '*'
                printf "Please answer y or n.\n" >&2
        end
    end
end


function fish_remove_path --description "Interactively remove entries from fish_user_paths"
    if not type -q fzf
        printf "fzf is required but not installed\n" >&2
        return 1
    end

    # Ensure variable exists as a list
    set -q fish_user_paths; or set -g fish_user_paths

    if test (count $fish_user_paths) -eq 0
        printf "fish_user_paths is empty\n" >&2
        return 0
    end

    # Present as lines; allow multi-select with Tab
    set -l selection (printf "%s\n" $fish_user_paths | fzf --multi --prompt="Select path(s) to remove: ")
    if test -z "$selection"
        printf "No selection.\n" >&2
        return 0
    end

    # Build a remaining list excluding all selected
    set -l selected_list (string split \n -- "$selection")
    set -l remaining
    for p in $fish_user_paths
        if not contains -- "$p" $selected_list
            set remaining $remaining $p
        end
    end

    set -U fish_user_paths $remaining
    printf "Updated fish_user_paths. Removed:\n" >&2
    for s in $selected_list
        printf " - %s\n" "$s" >&2
    end
end

function log --description "Log helper with colored output: debug, info, warn, error"
    set -l level (string lower -- (string trim -- "$argv[1]"))
    set -l message (string join ' ' -- $argv[2..-1])

    # Level gating
    set -l current (string lower -- "$LOG_LEVEL")
    if test "$DEBUG" = 1 -o "$DEBUG" = true
        set current debug
    end
    switch $level
        case debug
            switch $current
                case debug
                case '*'
                    return
            end
    end

    switch $level
        case debug
            set_color magenta
            set -l prefix "[DEBUG] "
        case info
            set_color cyan
            set -l prefix ""
        case warn warning
            set_color yellow
            set -l prefix "[WARNING] "
        case error
            set_color red
            set -l prefix "[ERROR] "
        case '*'
            set_color normal
            set -l prefix ""
    end

    printf "%s%s\n" "$prefix" "$message"
    set_color normal
end

function yn --description "Ask for confirmation before running a command"
    if test (count $argv) -eq 0
        printf "Usage: yn <command> [args...]\n" >&2
        return 2
    end

    # Show the command to be run
    printf "Run [ %s ] Y/N: " (string join ' ' -- $argv) >&2
    read -l confirm
    switch $confirm
        case Y y yes YES Yes
            command $argv
            return $status
        case '*'
            printf "Aborted\n" >&2
            return 1
    end
end
