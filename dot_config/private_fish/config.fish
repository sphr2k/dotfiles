### fish greeting
set fish_greeting

### Additional configs
for file in $HOME/.config/fish/config.fish.d/*.fish
    source $file
end

### path
fish_add_path --path $HOME/bin
fish_add_path --path $HOME/scripts
fish_add_path --path $HOME/go/bin

### onedark-fish
if status is-interactive
    set -l onedark_options -b

    if set -q VIM
        # Using from vim/neovim.
        set onedark_options -256
    else if string match -iq "eterm*" $TERM
        # Using from emacs.
        function fish_title
            true
        end
        set onedark_options -256
    end

    set_onedark $onedark_options
end

### fzf
set -gx fzf_preview_dir_cmd eza --all --color=always

### Editor
set -gx EDITOR /opt/homebrew/bin/code --wait
set -gx VISUAL /opt/homebrew/bin/code --wait
set -gx KUBE_EDITOR /opt/homebrew/bin/code --wait

### Alias
alias cls='clear'

alias dc='docker compose'
alias gdu='gdu-go'
alias k='kubectl'

alias kevents='kubectl get events --sort-by=".metadata.creationTimestamp"'
alias kpfw='kubectl port-forward'
alias kpodshell='kubectl exec -it $(kubectl get pods --no-headers -o custom-columns=":metadata.name" | fzf) -- sh -c "bash || sh || ash"'
alias knodeshell='kubectl debug --image docker.io/library/ubuntu:22.04 -it node/$(kubectl get nodes --no-headers -o custom-columns=":metadata.name" | fzf) -- chroot /host sh -c "bash || sh || ash"'
alias ktemp='set FILE "/tmp/$(uuidgen).yaml" && code -w $FILE && kubectl apply -f $FILE'

alias ls='eza -l --icons --group-directories-first --time-style long-iso'
alias ofd='open $PWD'
alias reload='source ~/.config/fish/config.fish'
alias sed='gsed'
alias unblock='xattr -d com.apple.quarantine'
alias git-history='git log --graph --decorate --oneline --all --full-history --pretty=format:"%C(auto)%h%Creset %ad %s %C(auto)%d%Creset %C(bold blue)<%aN>%Creset" --date=short --abbrev=8'


### AWS CLIv2 completion: https://github.com/aws/aws-cli/issues/1079
complete --command aws --no-files --arguments '(begin; set --local --export COMP_SHELL fish; set --local --export COMP_LINE (commandline); aws_completer | sed \'s/ $//\'; end)'

### direnv
direnv hook fish | source

### kubeswitch
switcher init fish | source
function kswitch --wraps switcher
    kubeswitch $argv
end
function kns --wraps switcher
    kubeswitch ns $argv
end
