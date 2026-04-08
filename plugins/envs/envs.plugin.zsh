export FNM_PATH="/opt/homebrew/opt/fnm/bin"
export GPG_TTY=$(tty)
export LC_ALL=en_US.UTF-8
export ANDROID_HOME=~/Library/Android/sdk
export ANDROID_SDK_ROOT=~/Library/Android/sdk
export ANDROID_AVD_HOME=~/.android/avd
export BUN_INSTALL="$HOME/.bun"
ZSH_DISABLE_COMPFIX=true
if [ -f ~/Gateway_CA_-_Cloudflare_Managed_G1.pem ]; then
  export NODE_EXTRA_CA_CERTS=~/Gateway_CA_-_Cloudflare_Managed_G1.pem
fi
