# Git Aliases and Functions

# Branch switching
alias dev='git checkout develop'
alias prod='git checkout master'
alias pull='git pull'
alias devpull='git checkout develop && git pull'
alias prodpull='git checkout master && git pull'

# Pretty log
alias gl="git log --graph --pretty=format:'%C(yellow)%d%Creset %C(cyan)%h%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=short --all"

# Git add, commit, push in one command
gacp() {
  gaa
  gc -m "$1"
  gp
}

# Clean up deleted remote branches
alias gdump="git fetch -p && git branch -vv | awk '/: gone]/{print $1}' | xargs git branch -D"
