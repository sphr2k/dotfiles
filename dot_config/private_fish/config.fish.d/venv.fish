# Automatically activate/deactivate virtualenv on directory change, with an exception for Poetry projects.
function __auto_source_venv --on-variable PWD --description "Activate/Deactivate virtualenv on directory change"
  status --is-command-substitution; and return

  # Find the project root by searching upwards for a marker file.
  set project_root ""
  set cwd (pwd -P)
  while test "$cwd" != "/"
    if test -e "$cwd/.venv/bin/activate.fish" -o -e "$cwd/poetry.lock"
      set project_root "$cwd"
      break
    end
    set cwd (path dirname "$cwd")
  end

  # --- Case 1: We are inside a project directory (either standard or Poetry) ---
  if test -n "$project_root"
    # It's a Poetry project. We should not have an active venv unless it's this one.
    if test -e "$project_root/poetry.lock"
      # If a venv is active, and it's NOT the one for this poetry project, deactivate it.
      if test -n "$VIRTUAL_ENV" -a "$VIRTUAL_ENV" != "$project_root/.venv"
        deactivate
        if status --is-interactive
          echo -e (set_color yellow)"Deactivated venv upon entering Poetry project."(set_color normal)
        end
      end
      return # We're done. No auto-activation for Poetry projects.
    
    # It's a standard project with a .venv.
    else if test -e "$project_root/.venv/bin/activate.fish"
      # Activate it if we are not already in it.
      if test "$VIRTUAL_ENV" != "$project_root/.venv"
        source "$project_root/.venv/bin/activate.fish"
        if status --is-interactive
          echo -e (set_color cyan)"Activated virtual environment from $project_root/.venv"(set_color normal)
        end
      end
      return # We're done.
    end
  end

  # --- Case 2: We are outside any known project directory ---
  # If a venv is active, it must be from a previous project, so deactivate it.
  if test -n "$VIRTUAL_ENV"
      # Check if the active venv belongs to a Poetry project to avoid deactivating a `poetry shell`.
      set venv_root (path dirname (path dirname "$VIRTUAL_ENV"))
      if test -e "$venv_root/poetry.lock"
          # This was likely activated by `poetry shell`, so leave it alone.
          return
      end

      # It's a standard venv we can safely deactivate.
      set venv_path "$VIRTUAL_ENV"
      deactivate
      if status --is-interactive
        echo -e (set_color yellow)"Deactivated virtual environment: $venv_path"(set_color normal)
      end
  end
end
