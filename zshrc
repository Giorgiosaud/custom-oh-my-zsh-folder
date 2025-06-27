# Amazon Q pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
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
	zsh-256color
	vscode
	codeclimate-run
	zsh-syntax-highlighting
	node-modules-optimize
	npm
	brew
)
ZSH_DISABLE_COMPFIX=true
source $ZSH/oh-my-zsh.sh

export GPG_TTY=$(tty)

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export PATH="/usr/local/sbin:$PATH"
export PATH="/usr/local/opt/elasticsearch@2.4/bin:$PATH"
export PATH="/usr/local/opt/openssl@1.1/bin:$PATH"
export PATH=/usr/local/bin/php:$PATH
fpath+=$HOME/.oh-my-zsh/custom/pure
export PATH="$HOME/.amplify/bin:$PATH"
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

export PNPM_HOME="/Users/giorgiosaud/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
# bun completions
[ -s "/Users/giorgiosaud/.bun/_bun" ] && source "/Users/giorgiosaud/.bun/_bun"
# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
# rvm
export PATH="/Users/giorgiosaud/.rvm/bin:$PATH" #UNCOMMENTED
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"

PATH=~/.console-ninja/.bin:$PATH

# # Fnm Fast node manager setting
# FNM_PATH="/Users/giorgiosaud/Library/Application Support/fnm"
if [ -d "$FNM_PATH" ]; then
	export PATH="/Users/giorgiosaud/Library/Application Support/fnm:$PATH"
	eval "`fnm env`"
fi
eval "$(fnm env --use-on-cd --shell zsh)"
# # Add this near the top of your .zshrc file
if [[ "$TERM_PROGRAM" == "vscode" ]]; then
 	# typeset -g POWERLEVEL9K_INSTANT_PROMPT=off
 fi
