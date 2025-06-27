# Amazon Q pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
eval "$(/opt/homebrew/bin/brew shellenv)"
export ZSH=~/.oh-my-zsh
export SONAR_HOME=/usr/local/Cellar/sonar-scanner/{version}/libexec
export SONAR=$SONAR_HOME/bin export PATH=$SONAR:$PATH
plugins=(
	envs
	paths
	git
	reset-intelij
	zsh-autosuggestions
	vscode
	zsh-syntax-highlighting
	node-modules-optimize
	zsh-vi-mode
)


source $ZSH/oh-my-zsh.sh


[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

fpath+=$HOME/.oh-my-zsh/custom/pure
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
# bun completions
# # Fnm Fast node manager setting
# FNM_PATH="/Users/giorgiosaud/Library/Application Support/fnm"

# eval "$(fnm env --use-on-cd --shell zsh)"
# # Add this near the top of your .zshrc file
if [[ "$TERM_PROGRAM" == "vscode" ]]; then
 	typeset -g POWERLEVEL9K_INSTANT_PROMPT=off
fi
