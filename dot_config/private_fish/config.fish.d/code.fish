function code
    # Check if arguments are provided
    if test (count $argv) -eq 0
        # Get the root of the Git repository
        set git_root (git rev-parse --show-toplevel 2>/dev/null)

        # Check if the current directory is in a Git repository
        if test -n "$git_root"
            # Open the repository root in VS Code
            command code "$git_root"
        else
            # Open the current directory in VS Code if not in a Git repository
            command code .
        end
    else
        # Pass through any arguments to the `code` binary
        command code $argv
    end
end
