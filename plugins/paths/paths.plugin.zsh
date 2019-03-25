# Add your own custom plugins in the custom/plugins directory. Plugins placed
# here will override ones with the same name in the main plugins directory.
if [ -f ~/.composer/vendor/bin ]; then
export PATH=$PATH:~/.composer/vendor/bin
fi

if [ -f ./vendor/bin ]; then
export PATH=$PATH:./vendor/bin
fi
if [ -f ~/.oh-my-zsh/custom/aliases ]; then
	source ~/.oh-my-zsh/custom/aliases
else
	print "404: ~/.oh-my-zsh/custom/aliases not found."
fi
export ANDROID_HOME="$HOME/Library/Android/sdk"
PATH=$PATH:$ANDROID_HOME/tools; PATH=$PATH:$ANDROID_HOME/platform-tools
