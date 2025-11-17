# Amazon Q pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh"

# Powerlevel10k theme configuration
ZSH_THEME="powerlevel10k/powerlevel10k"

export ZSH=~/.oh-my-zsh

# Performance: Enable completion cache (rebuilds only once per day)
autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi
export SONAR_HOME=/usr/local/Cellar/sonar-scanner/{version}/libexec
export SONAR=$SONAR_HOME/bin
export PATH=$SONAR:$PATH
plugins=(
	envs
	paths
	git
	reset-intelij
	vscode
	zsh-vi-mode
	lazy-load
	apple-secret
	aliases
	async-loader
	lazy-version-managers
	smart-npm
	docker-utils
	zsh-monitor
)

source $ZSH/oh-my-zsh.sh

fpath+=$HOME/.oh-my-zsh/custom/pure
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# VSCode-specific configuration
if [[ "$TERM_PROGRAM" == "vscode" ]]; then
 	typeset -g POWERLEVEL9K_INSTANT_PROMPT=off
fi

# Secure secret management via apple-secret plugin
export GITHUB_TOKEN=$(get-secret "github_token")
export GITHUB_USERNAME=giorgiosaud

