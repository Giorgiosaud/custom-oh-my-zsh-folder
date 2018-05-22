# Add your own custom plugins in the custom/plugins directory. Plugins placed
# here will override ones with the same name in the main plugins directory.
path+=("/usr/local/Cellar/phplint/3.0-20160307/bin")
path+=("./vendor/bin")
export PATH
if [ -f ~/.aliases ]; then
	source ~/.aliases
else
	print "404: ~/.aliases not found."
fi
