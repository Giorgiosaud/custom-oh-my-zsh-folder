# Amazon Q pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh"

# Powerlevel10k theme configuration
ZSH_THEME="powerlevel10k/powerlevel10k"

export ZSH=~/.oh-my-zsh
export SONAR_HOME=/usr/local/Cellar/sonar-scanner/{version}/libexec
export SONAR=$SONAR_HOME/bin
export PATH=$SONAR:$PATH
plugins=(
	envs
	paths
	git
	reset-intelij
	vscode
	node-modules-optimize
	zsh-vi-mode
	lazy-load  
	apple-secret
	aliases
)

source $ZSH/oh-my-zsh.sh

# FZF fuzzy finder integration
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

fpath+=$HOME/.oh-my-zsh/custom/pure
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

# VSCode-specific configuration
if [[ "$TERM_PROGRAM" == "vscode" ]]; then
 	typeset -g POWERLEVEL9K_INSTANT_PROMPT=off
fi

# Secure secret management via apple-secret plugin
export GITHUB_TOKEN=$(get-secret "github_token")
export GITHUB_USERNAME=giorgiosaud

