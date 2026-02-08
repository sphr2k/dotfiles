# Automatically activate/deactivate virtualenv on directory change, regardless of Git
function __auto_source_venv --on-variable PWD --description "Activate/Deactivate virtualenv on directory change"
  status --is-command-substitution; and return

  # Start from the current directory and move upwards
  set cwd (pwd -P)
  while test "$cwd" != "/"
    if test -e "$cwd/.venv/bin/activate.fish"
      # If a virtual environment is found, activate it
      if test -z "$VIRTUAL_ENV" -o "$VIRTUAL_ENV" != "$cwd/.venv"
        source "$cwd/.venv/bin/activate.fish"
        echo -e (set_color cyan)"Activated virtual environment from $cwd/.venv"(set_color normal)
      end
      return
    end
    # Move up one directory
    set cwd (path dirname "$cwd")
  end

  # If no virtual environment is found and one is currently active, deactivate it
  if test -n "$VIRTUAL_ENV"
    set venv_path "$VIRTUAL_ENV"
    deactivate
    echo -e (set_color yellow)"Deactivated virtual environment: $venv_path"(set_color normal)
  end
end
