# For Ubuntu use ubuntu_setup.sh
chmod +x ubuntu-setup.sh
./ubuntu-setup.sh



## FOr windows following will work
# os-shell

cat ~/.bashrc | clip


>> in .bashrc following 

# Starship prompt
eval "$(starship init bash)"

# Python virtualenv
export VIRTUAL_ENV_DISABLE_PROMPT=0

# NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# History configuration
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoredups:erasedups
shopt -s histappend

# Append history saving commands to existing PROMPT_COMMAND
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND ;} history -a; history -n"



# git Oh-My-Zsh style aliases
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gapa='git add --patch'
alias gb='git branch'
alias gba='git branch -a'
alias gbd='git branch -d'
alias gbD='git branch -D'
alias gbl='git blame -b -w'
alias gbnm='git branch --no-merged'
alias gbr='git branch --remote'
alias gbs='git bisect'
alias gbsb='git bisect bad'
alias gbsg='git bisect good'
alias gbsr='git bisect reset'
alias gbss='git bisect start'

alias gc='git commit -v'
alias 'gc!'='git commit -v --amend'
alias gcn!='git commit -v --no-edit --amend'
alias gca='git commit -v -a'
alias gca!='git commit -v -a --amend'
alias gcan!='git commit -v -a --no-edit --amend'
alias gcans!='git commit -v -a -s --no-edit --amend'
alias gcam='git commit -a -m'
alias gcmsg='git commit -m'

alias gcl='git clone --recurse-submodules'
alias gccd='git clone --recurse-submodules "$@" && cd "$(basename $_ .git)"'

alias gd='git diff'
alias gdca='git diff --cached'
alias gds='git diff --staged'

alias gf='git fetch'
alias gfa='git fetch --all --prune'

alias gg='git gui citool'
alias ggf='git push --force origin $(git_current_branch)'

alias ggl='git pull origin $(git_current_branch)'
alias ggp='git push origin $(git_current_branch)'
alias ggpsup='git push --set-upstream origin $(git_current_branch)'

alias gl='git pull'
alias gp='git push'

alias gr='git remote'
alias grb='git rebase'
alias grba='git rebase --abort'
alias grbc='git rebase --continue'
alias grs='git restore'
alias grss='git restore --source'

alias gs='git status'
alias gss='git status -s'

alias gst='git status'
alias gsta='git stash push'
alias gstp='git stash pop'
alias gstl='git stash list'

alias gsw='git switch'
alias gswc='git switch -c'

alias gts='git tag -s'
