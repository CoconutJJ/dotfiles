. "$HOME/.cargo/env"
export CC=$(which gcc)
export PATH=$PATH:/opt/homebrew/Cellar/llvm/17.0.6/bin:"/Users/david/.local/bin"
export LATEXINDENT_CONFIG="/Users/david/Documents/Programming/dotfiles/indentconfig.yaml"
export BAT_PAGER="less -X"
export PATH="/opt/homebrew/opt/make/libexec/gnubin:$PATH"

eval "$(fzf --zsh)"
eval "$(zoxide init zsh)"
eval "$(thefuck --alias)"

export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix'

show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"

_fzf_comprun() {
    local command=$1
    shift

    case "$command" in
    cd) fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export | unset) fzf --preview "eval 'echo $'{}" "$@" ;;
    ssh) fzf --preview 'dig {}' "$@" ;;
    *) fzf --preview $show_file_or_dir_preview "$@" ;;
    esac
}

help() {
    "$@" --help 2>&1 | bat --plain --language=help 1>&2
}

autoload -U history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^[[A" history-beginning-search-backward-end
bindkey "^[[B" history-beginning-search-forward-end

alias lgit="lazygit"
alias cd="z"
alias s="fzf"
alias cat="bat"
alias ls='eza --long --icons --no-user --no-time'
alias tree='eza --tree --icons'
alias tkill='tmux kill-session -t'
alias tls='tmux ls'
