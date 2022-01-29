# If not running interactively, don't do anything
[[ $- != *i* ]] && return


if [ -x "$(command -v tmux)" ] && [ -n "${DISPLAY}" ]; then
      [ -z "${TMUX}" ] && { tmux attach || tmux; } >/dev/null 2>&1
fi

PATH="${PATH}:/home/david/.local/bin"
PATH="${PATH}:/home/david/.local/share/gem/ruby/3.0.0/bin"
PATH="${PATH}:/home/david/.stack/programs/x86_64-linux/ghc-tinfo6-8.10.4/bin" 
PATH="${PATH}:$(yarn global bin)"
PATH="${PATH}:/usr/lib/docker/cli-plugins"

export XDG_CONFIG_HOME="$HOME/.config"
export PATH

# FZF Configuration
export FZF_COMPLETION_TRIGGER='**'
export FZF_COMPLETION_OPTS='--border --info=inline'
_fzf_compgen_path() {
  find "$1" -type f -not -path "**/node_modules/**" -not -path "**/.vscode-server/**" -not -path "**/.git/**" 2> /dev/null 
}
_fzf_compgen_dir() {
  find "$1" -type d -not -path "**/node_modules/**" -not -path ".vscode-server/**" -not -path "**/.git/**" 2> /dev/null
}
source "/usr/share/fzf/completion.zsh"

# Zsh Autosuggestion Plugin Configuration
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=244"
ZSH_AUTOSUGGEST_STRATEGY=(completion history)
source "/home/david/.config/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"

# Zsh Syntax Highlighting Plugin Configuration
source "/home/david/.config/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"


# Zsh Git Prompt
autoload -Uz vcs_info
precmd(){ vcs_info }
setopt PROMPT_SUBST
zstyle ':vcs_info:git:*' formats ' (%F{yellow}%b%F{white})'

function preexec() {
    timer=${timer:-$SECONDS}
}

function precmd() {
    if [ $timer ]; then
        timer_show=$(($SECONDS - $timer))
        timer_show=$(printf '%.*f\n' 3 $timer_show)
  	export RPROMPT="${vcs_info_msg_0_} %t [took ${timer_show}] [%?]"
      
        unset timer
    fi
}


NEWLINE=$'\n'
# Prompt Configuration
PROMPT="%F{046}%n@%m:%F{yellow}%~ %F{blue}${NEWLINE}$%F{white} "
# RPROMPT='${vcs_info_msg_0_} %t %D [%?]'

export TERM=xterm-256color


# Open command
alias open='xdg-open'
alias ls='ls --color'
alias clipboard='xclip -sel clip'
alias rm='trash-put'
alias hacker='docker run --rm -v $(pwd):/root -w /root -it hacker'
alias p='python'
export EDITOR='vim'
export GOPATH="$HOME/.config/go"

source /usr/share/nvm/init-nvm.sh
