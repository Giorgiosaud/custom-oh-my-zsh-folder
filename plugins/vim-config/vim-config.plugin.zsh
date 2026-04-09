# vim-config plugin
# Manages vimrc symlink and vim-plug bootstrap from this repo.

{
  _vim_plugin_dir="${0:A:h}"
  _vim_target="$HOME/.vimrc"
  _vim_source="$_vim_plugin_dir/vimrc"

  # Symlink ~/.vimrc to our vimrc (skip if already correct)
  if [[ "$(readlink "$_vim_target" 2>/dev/null)" != "$_vim_source" ]]; then
    [[ -f "$_vim_target" || -L "$_vim_target" ]] && rm -f "$_vim_target"
    ln -s "$_vim_source" "$_vim_target"
  fi

  # Symlink ~/.vim → nothing needed, plugged dir stays at ~/.vim/plugged

  unset _vim_plugin_dir _vim_target _vim_source
} &>/dev/null
