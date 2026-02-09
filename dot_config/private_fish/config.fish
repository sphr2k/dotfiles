### Prompt
set fish_greeting
set -gx VIRTUAL_ENV_DISABLE_PROMPT 1

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
set -gx EDITOR $HOME/scripts/code --wait
set -gx VISUAL $HOME/scripts/code --wait
set -gx KUBE_EDITOR $HOME/scripts/code --wait

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
