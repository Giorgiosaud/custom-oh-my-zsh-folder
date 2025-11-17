#Alias edit hosts
#git
alias dev='git checkout develop'
alias prod='git checkout master'
alias pull='git pull'
alias devpull='git checkout develop && git pull'
alias prodpull='git checkout master && git pull'

#@modyo/cli
alias myc='modyo-cli create'
alias mys='modyo-cli start'
alias myl='modyo-cli login'
alias myo='modyo-cli logout'
alias myp='modyo-cli push'
#GITHUB
alias gl="git log --graph --pretty=format:'%C(yellow)%d%Creset %C(cyan)%h%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=short --all"
alias reload="source ~/.zshrc"
#add new branch
gacp(){
gaa
gc -m "$1"
gp
}
alias gdump="git fetch -p && git branch -vv | awk '/: gone]/{print $1}' | xargs git branch -D"
function runCommand() {
    for d in ./*/ ; do /bin/zsh -c "(cd "$d" && "$@")"; done
}
