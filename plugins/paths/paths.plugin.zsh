# Add your own custom plugins in the custom/plugins directory. Plugins placed
# here will override ones with the same name in the main plugins directory.
if [ -f ~/.composer/vendor/bin ]; then
    A
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
if [ -f /Users/Jorge/Library/Application\ Support/Code/User/globalStorage/ms-vscode-remote.remote-containers/cli-bin ]; then
  export PATH=$PATH:/Users/Jorge/Library/Application\ Support/Code/User/globalStorage/ms-vscode-remote.remote-containers/cli-bin
fi
export ANDROID_HOME="$HOME/Library/Android/sdk"
PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:~/.composer/vendor/bin:~/seleniumDrivers/:~/Projects/sonar-bin/bin

