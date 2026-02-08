# dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/).

## Bootstrap

### 1. Install Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. Install chezmoi

```bash
brew install chezmoi
```

### 3. Apply your dotfiles & Brewfile

This will clone the repo and run `chezmoi apply` (replaces your user/repo).

```bash
chezmoi init --apply https://github.com/sphr2k/dotfiles.git
```

With `chezmoi init --apply <repo>`, the `run_brew_bundle.sh` hook runs during apply (brew bundle, fisher, tide). If you use `chezmoi init --apply --source .` (local dir), run it yourself after apply:

```bash
./run_brew_bundle.sh
```
