function checkmodules(){
  find . -name "node_modules" -type d -prune | xargs du -chs
}
function removenodemodules(){
 find . -name "node_modules" -type d -prune -exec rm -rf '{}' +
}
