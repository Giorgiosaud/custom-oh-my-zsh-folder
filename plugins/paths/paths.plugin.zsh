if [ -d ~/.local/bin ]; then
export PATH=$PATH:~/.local/bin
fi
if [ -f ~/.composer/vendor/bin ]; then
export PATH=$PATH:~/.composer/vendor/bin
fi

if [ -f ./node_modules/.bin ]; then
export PATH=$PATH:./node_modules/.bin
fi
if [ -f ./vendor/bin ]; then
export PATH=$PATH:./vendor/bin
fi
if [ -f ~/.oh-my-zsh/custom/aliases ]; then
source ~/.oh-my-zsh/custom/aliases
else
print "404: ~/.oh-my-zsh/custom/aliases not found."
fi
if [ -f ~/Project/sonar-bin/bin ]; then
source ~/Project/sonar-bin/bin
fi
if [ -f /usr/local/sbin ]; then
source /usr/local/sbin
fi
if [ -f ~/Library/Application\ Support/Code/User/globalStorage/ms-vscode-remote.remote-containers/cli-bin ]; then
export PATH=$PATH:~/Library/Application\ Support/Code/User/globalStorage/ms-vscode-remote.remote-containers/cli-bin
fi
if [ -d ~/.pyenv/shims ]; then
export PATH=$PATH:~/.pyenv/shims
fi
if [ -d ~/.rvm/scripts/rvm ]; then
export PATH=$PATH:~/.rvm/bin
fi
if [ -d ~/.bun/bin ]; then
export PATH=$PATH:~/.bun/bin
fi
if [ -d ~/.console-ninja/.bin ]; then
export PATH=$PATH:~/.console-ninja/.bin
fi
if [ -d ~/.amplify/bin ]; then
export PATH=$PATH:~/.amplify/bin
fi
if [ -d "$FNM_PATH" ]; then
export PATH=$PATH:~/Library/Application Support/fnm
eval "$(fnm env --use-on-cd --shell zsh)"
fi
if [ -d /usr/local/opt/elasticsearch@2.4/bin ]; then
export PATH=$PATH:/usr/local/opt/elasticsearch@2.4/bin
fi
if [ -d /usr/local/opt/openssl@1.1/bin ]; then
export PATH=$PATH:/usr/local/opt/openssl@1.1/bin
fi
# bun
if [ -d "$BUN_INSTALL/bin" ]; then
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "~/.bun/_bun" ] && source "~/.bun/_bun"
fi
if [ -d ~/.rvm/bin ]; then
export PATH=$PATH:~/.rvm/bin #UNCOMMENTED
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"
fi
