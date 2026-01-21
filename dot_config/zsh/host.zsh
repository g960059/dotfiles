export PS1="%1~ %# "
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/hirakawa/miniforge3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/hirakawa/miniforge3/etc/profile.d/conda.sh" ]; then
        . "/Users/hirakawa/miniforge3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/hirakawa/miniforge3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<


# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/hirakawa/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/hirakawa/Downloads/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/hirakawa/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/hirakawa/Downloads/google-cloud-sdk/completion.zsh.inc'; fi

#[ -f "/Users/hirakawa/.ghcup/env" ] && source "/Users/hirakawa/.ghcup/env" # ghcup-env
[ -f "/Users/hirakawa/.ghcup/env" ] && source "/Users/hirakawa/.ghcup/env" # ghcup-env

export PATH="$HOME/.cargo/bin:$PATH"


# Added by Antigravity
export PATH="/Users/hirakawa/.antigravity/antigravity/bin:$PATH"

export ENV_KIND="HOST"
export HM_TARGET=hirakawa

