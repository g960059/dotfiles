eexport NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
eval "$(sheldon source)"
# Pure の user@host を UTM_VM に
if (( ${+prompt_pure_state} )) && [[ -n ${prompt_pure_state[username]-} ]]; then
  prompt_pure_state[username]='%F{${prompt_pure_colors[user]}}UTM_VM%f'
fi


# Added by Antigravity
export PATH="/Users/virtualmachine/.antigravity/antigravity/bin:$PATH"
alias vim='nvim'
xport PATH="$PATH:$(go env GOPATH)/bin"

# Google Cloud SDK
source /Users/virtualmachine/google-cloud-sdk/path.zsh.inc
source /Users/virtualmachine/google-cloud-sdk/completion.zsh.inc

# uv (Python) for gcloud
export PATH="/Users/virtualmachine/.local/bin:$PATH"
export CLOUDSDK_PYTHON="/Users/virtualmachine/.local/share/uv/python/cpython-3.11.14-macos-aarch64-none/bin/python3.11"

export ENV_KIND="VM"

