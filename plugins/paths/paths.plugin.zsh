# Add your own custom plugins in the custom/plugins directory. Plugins placed
# here will override ones with the same name in the main plugins directory.
export PATH=$PATH:~/.composer/vendor/bin:vendor/bin
if [ -f ~/.oh-my-zsh/custom/aliases ]; then
	source ~/.oh-my-zsh/custom/aliases
else
	print "404: ~/.oh-my-zsh/custom/aliases not found."
fi
