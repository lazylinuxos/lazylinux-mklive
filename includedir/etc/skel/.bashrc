# .bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

if [ -f ~/.bash_aliases ]; then 
    . ~/.bash_aliases;
fi

if [ -f ~/.bash_functions ]; then 
    . ~/.bash_functions;
fi

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

eval "$(oh-my-posh init bash --config ~/.poshthemes/tiwahu.omp.json)"
eval "$(zoxide init bash)"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PATH=$HOME/.nix-profile/bin:$HOME/.cargo/bin:$PATH
export XDG_DATA_DIRS=~/.nix-profile/share:$XDG_DATA_DIRS
