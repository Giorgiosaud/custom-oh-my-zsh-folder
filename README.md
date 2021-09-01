# custom-oh-my-zsh-folder
## Instructions
1. Add [oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh#basic-installation) to your installation
2. Go to ~/.oh-my-zsh in your terminal
3. Remove base custom folder ```shell rm -rf custom```
4. Clone this repo and its modules in the same folder ```shell git clone --recurse-submodules git@github.com:Giorgiosaud/custom-oh-my-zsh-folder.git custom```
5. Go to your home directory ```shell cd ~```
6. Delete your zsh config ```shell rm .zshrc```
7. Create an alias to the zshrc file in the home directory ```shell ln -s .oh-my-zsh/custom/zshrc .zshrc```

> If you like you can fork this repo and follow the same instructions changing yout github reference
