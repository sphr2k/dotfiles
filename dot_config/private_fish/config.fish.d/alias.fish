### Alias
alias cls='clear'

### Misc
alias gdu='gdu-go'
alias ofd='open $PWD'
alias reload='source ~/.config/fish/config.fish'
alias sed='gsed'
alias unblock='xattr -d com.apple.quarantine'

### Docker
alias dc='docker compose'

### Kubernetes
alias k='kubectl'
alias kevents='kubectl get events --sort-by=".metadata.creationTimestamp"'
alias kpfw='kubectl port-forward'
alias kpodshell='kubectl exec -it $(kubectl get pods --no-headers -o custom-columns=":metadata.name" | fzf) -- sh -c "bash || sh || ash"'
alias knodeshell='kubectl debug --image docker.io/library/ubuntu:22.04 -it node/$(kubectl get nodes --no-headers -o custom-columns=":metadata.name" | fzf) -- chroot /host sh -c "bash || sh || ash"'
alias ktemp='set FILE "/tmp/$(uuidgen).yaml" && code -w $FILE && kubectl apply -f $FILE'

### Git
alias git-history='git log --graph --decorate --oneline --all --full-history --pretty=format:"%C(auto)%h%Creset %ad %s %C(auto)%d%Creset %C(bold blue)<%aN>%Creset" --date=short --abbrev=8'

alias gc='git commit'
alias gca='git commit --amend'
alias gcam='git commit --amend --no-edit'

alias gco='git checkout'
alias gcb='git checkout -b'
alias gcm='git checkout main'

alias gpl='git pull'
alias gps='git push'

