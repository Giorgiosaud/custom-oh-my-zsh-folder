ZSH_THEME="powerlevel10k/powerlevel10k"
# Fig pre block. Keep at the top of this file.
[[ -f "$HOME/.fig/shell/zshrc.pre.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.pre.zsh"
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

eval "$(/opt/homebrew/bin/brew shellenv)"
export ZSH=~/.oh-my-zsh
export SONAR_HOME=/usr/local/Cellar/sonar-scanner/{version}/libexec
export SONAR=$SONAR_HOME/bin export PATH=$SONAR:$PATH
plugins=(
npm-completion
git
reset-intelij
paths
envs
zsh-autosuggestions
locale
bd
zsh-256color
vscode
codeclimate-run
zsh-syntax-highlighting
node-modules-optimize
zsh-vi-mode
npm
brew
zsh-history-substring-search
)
ZSH_DISABLE_COMPFIX=true
source $ZSH/oh-my-zsh.sh

# User configuration

# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

if [ -f /Users/jorgesaud/.tnsrc ]; then
source /Users/jorgesaud/.tnsrc
fi

###-tns-completion-end-###
export GPG_TTY=$(tty)
#export NVM_DIR="$HOME/.nvm"
#[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
#[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion
#nvm end

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export PATH="/usr/local/sbin:$PATH"

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

export PATH="/usr/local/opt/elasticsearch@2.4/bin:$PATH"

export PATH="/usr/local/opt/openssl@1.1/bin:$PATH"
export PATH=/usr/local/bin/php:$PATH

fpath+=$HOME/.oh-my-zsh/custom/pure
#autoload -U promptinit; promptinit
#prompt bart

# Added by Amplify CLI binary installer
export PATH="$HOME/.amplify/bin:$PATH"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

export PNPM_HOME="/Users/giorgiosaud/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

NODE_TLS_REJECT_UNAUTHORIZED=0

# bun completions
[ -s "/Users/giorgiosaud/.bun/_bun" ] && source "/Users/giorgiosaud/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Fig post block. Keep at the bottom of this file.
[[ -f "$HOME/.fig/shell/zshrc.post.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.post.zsh"
# rvm
export PATH="/Users/giorgiosaud/.rvm/bin:$PATH" #UNCOMMENTED
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"


PATH=~/.console-ninja/.bin:$PATH
PATH=~/.console-ninja/.bin:$PATH
PATH=~/.console-ninja/.bin:$PATH
PATH=~/.console-ninja/.bin:$PATH

# Fnm Fast node manager setting
FNM_PATH="/Users/giorgiosaud/Library/Application Support/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="/Users/giorgiosaud/Library/Application Support/fnm:$PATH"
  eval "`fnm env`"
fi
eval "$(fnm env --use-on-cd --shell zsh)"

