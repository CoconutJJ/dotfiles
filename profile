# ============================================================
# Rust / PATH / toolchain
# ============================================================
. "$HOME/.cargo/env"
export path=(
    "/usr/local/bin"
    "/opt/homebrew/opt/coreutils/libexec/gnubin"
    "/opt/homebrew/opt/make/libexec/gnubin"
    "/opt/homebrew/opt/llvm/bin"
    $path
    "/opt/homebrew/opt/binutils/bin"
    "/opt/aseprite/build/bin"
    "/Users/david/.local/bin"
)
export CC=$(which clang)
export CXX=$(which clang++)
export SDKROOT=$(xcrun --show-sdk-path)

# ============================================================
# Misc environment
# ============================================================
export LATEXINDENT_CONFIG="/Users/david/Documents/Programming/dotfiles/indentconfig.yaml"
export BAT_PAGER="less -X"
export XDG_CONFIG_HOME="/Users/david/.config"
export TERM=xterm-256color
export TERMINFO=/opt/homebrew/opt/ncurses/share/terminfo
export LESS="-R"
export EDITOR="hx"
# ============================================================
# fzf — core configuration
# ============================================================

# Default source: fd, include hidden, skip .git, follow symlinks
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --strip-cwd-prefix --exclude .git'

# Global defaults: layout, colors, useful bindings applied to every fzf invocation
export FZF_DEFAULT_OPTS="
  --height=80% --layout=reverse --border=rounded --info=inline
  --preview-window=right:60%:wrap
  --bind='ctrl-/:toggle-preview'
  --bind='ctrl-u:preview-half-page-up'
  --bind='ctrl-d:preview-half-page-down'
  --bind='ctrl-y:execute-silent(echo -n {} | pbcopy)+abort'
  --bind='alt-a:select-all'
  --bind='alt-d:deselect-all'
  --color=fg:#cdd6f4,bg:-1,hl:#f38ba8
  --color=fg+:#cdd6f4,bg+:#313244,hl+:#f38ba8
  --color=info:#cba6f7,prompt:#89b4fa,pointer:#f5e0dc
  --color=marker:#a6e3a1,spinner:#f5e0dc,header:#94e2d5
"

# Ctrl-T — insert fuzzy-picked file path into the command line
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="
  --preview 'bat -n --color=always --line-range :500 {}'
  --bind 'ctrl-/:change-preview-window(down|hidden|)'
"

# Alt-C — cd into a fuzzy-picked directory (tree preview)
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --strip-cwd-prefix --exclude .git'
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always --icons {} | head -200'"

# Ctrl-R — history search. {2..} strips the leading history number so
# ctrl-y copies just the command.
export FZF_CTRL_R_OPTS="
  --preview 'echo {}' --preview-window down:3:hidden:wrap
  --bind 'ctrl-/:toggle-preview'
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --header 'C-/ toggle preview | C-y copy command'
"

# Activate fzf key bindings + completion for zsh
eval "$(fzf --zsh)"

# Per-command preview for the **<TAB> completion trigger
show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always --icons {} | head -200; else bat -n --color=always --line-range :500 {}; fi"

_fzf_comprun() {
    local command=$1
    shift
    case "$command" in
        cd)           fzf --preview 'eza --tree --color=always --icons {} | head -200' "$@" ;;
        export|unset) fzf --preview "eval 'echo \$'{}" "$@" ;;
        ssh)          fzf --preview 'dig {}' "$@" ;;
        *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
    esac
}

# ============================================================
# fzf — workflow functions
# ============================================================

# fkill — interactively kill process(es). TAB to multi-select.
#   usage: fkill           (SIGKILL)
#          fkill 15        (SIGTERM)
fkill() {
    local pids
    pids=$(ps -ef | sed 1d | fzf -m --header='[kill: TAB to multi-select]' | awk '{print $2}')
    [ -n "$pids" ] && echo "$pids" | xargs kill -${1:-9}
}

# fbr — checkout a local git branch
fbr() {
    local branches branch
    branches=$(git --no-pager branch -vv) || return
    branch=$(echo "$branches" | fzf +m --preview 'git log --color=always --oneline -20 $(echo {} | awk "{print \$1}" | sed "s/^\*//")') || return
    git checkout $(echo "$branch" | awk '{print $1}' | sed 's/^\*//')
}

# fco — checkout any branch or tag (local + remote)
fco() {
    local tags branches target
    tags=$(git tag | awk '{print "\x1b[31;1mtag\x1b[m\t" $1}') || return
    branches=$(git branch --all | grep -v HEAD |
        sed 's/.* //; s#remotes/[^/]*/##' | sort -u |
        awk '{print "\x1b[34;1mbranch\x1b[m\t" $1}') || return
    target=$(printf "%s\n%s" "$tags" "$branches" | fzf --ansi +m) || return
    git checkout $(echo "$target" | awk '{print $2}')
}

# fgl — browse git log with live diff preview. C-y copies the commit hash.
fgl() {
    git log --graph --color=always \
        --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
    fzf --ansi --no-sort --reverse --tiebreak=index \
        --preview 'echo {} | grep -oE "[a-f0-9]{7,}" | head -1 | xargs -I % git show --color=always %' \
        --bind 'ctrl-y:execute-silent(echo {} | grep -oE "[a-f0-9]{7,}" | head -1 | pbcopy)+abort' \
        --header 'C-y copy commit hash'
}

# fga — stage files interactively. TAB to multi-select.
fga() {
    local files
    files=$(git -c color.status=always status --short |
        fzf -m --ansi --nth 2.. \
            --preview 'git diff --color=always -- $(echo {} | awk "{print \$2}") | head -500' |
        awk '{print $2}')
    [ -n "$files" ] && echo "$files" | xargs git add && git status --short
}

# fgst — browse stashes; Enter shows diff, C-d drops, C-b branches from it.
fgst() {
    local out key sha
    while out=$(
        git stash list --pretty='%C(yellow)%h %>(14)%Cgreen%cr %C(blue)%gs' |
        fzf --ansi --no-sort --reverse \
            --preview 'git stash show --color=always -p $(echo {} | cut -d" " -f1)' \
            --expect=ctrl-d,ctrl-b \
            --header='Enter: show | C-d: drop | C-b: branch'); do
        key=$(echo "$out" | head -1)
        sha=$(echo "$out" | sed -n 2p | cut -d' ' -f1)
        [ -z "$sha" ] && break
        case "$key" in
            ctrl-d) git stash drop "$sha" ;;
            ctrl-b) git stash branch "stash-${sha}" "$sha"; break ;;
            *)      git stash show -p "$sha" | bat --language=diff ;;
        esac
    done
}

# fssh — pick a Host entry from ~/.ssh/config and connect
fssh() {
    local host
    host=$(grep -E '^Host\s+' ~/.ssh/config 2>/dev/null |
        awk '{for(i=2;i<=NF;i++) print $i}' |
        grep -v '[*?]' | sort -u | fzf) || return
    ssh "$host"
}

# fta — attach to a tmux session, or create one named after $PWD
fta() {
    local session
    session=$(tmux list-sessions -F '#S' 2>/dev/null | fzf --exit-0) || {
        tmux new-session -s "${PWD##*/}"
        return
    }
    tmux attach -t "$session"
}


# fbrew — install a Homebrew formula via fzf (multi-select)
fbrew() {
    local pkgs
    pkgs=$(brew formulae | fzf --multi --preview 'brew info {}')
    [ -n "$pkgs" ] && echo "$pkgs" | xargs brew install
}

# fbrewu — uninstall Homebrew formula via fzf
fbrewu() {
    local pkgs
    pkgs=$(brew leaves | fzf --multi --preview 'brew info {}')
    [ -n "$pkgs" ] && echo "$pkgs" | xargs brew uninstall
}

# fpipi — install a pip package, picking the version interactively.
#   usage: fpipi numpy     # browse versions of numpy
#          fpipi           # prompt for a package name, then pick version
fpipi() {
    local pkg version
    if [ $# -eq 0 ]; then
        read "pkg?package: "
    else
        pkg=$1
    fi
    [ -z "$pkg" ] && return 1
    version=$(pip index versions "$pkg" 2>/dev/null |
        awk -F': ' '/Available versions:/ {print $2}' |
        tr ',' '\n' | sed 's/^ *//' |
        fzf --prompt="$pkg version> " --header='esc: install latest')
    if [ -z "$version" ]; then
        pip install "$pkg"
    else
        pip install "$pkg==$version"
    fi
}

# fpipup — upgrade outdated pip packages (multi-select).
fpipup() {
    local pkgs
    pkgs=$(pip list --outdated --format=columns 2>/dev/null |
        sed '1,2d' |
        fzf --multi --header='[pip upgrade: TAB multi-select]' \
            --preview 'pip show $(echo {} | awk "{print \$1}")' |
        awk '{print $1}')
    [ -n "$pkgs" ] && echo "$pkgs" | xargs pip install --upgrade
}

# fpipu — uninstall pip packages (multi-select). `pip show` as preview.
fpipu() {
    local pkgs
    pkgs=$(pip list --format=columns 2>/dev/null |
        sed '1,2d' |
        fzf --multi --header='[pip uninstall: TAB multi-select]' \
            --preview 'pip show $(echo {} | awk "{print \$1}")' |
        awk '{print $1}')
    [ -n "$pkgs" ] && echo "$pkgs" | xargs pip uninstall -y
}

# fe — open a file in $EDITOR (preview with bat)
fe() {
    local file
    file=$(fzf --preview 'bat -n --color=always --line-range :500 {}') || return
    "${EDITOR:-hx}" "$file"
}

# ============================================================
# help: pipe `--help` output through bat with syntax highlighting
# ============================================================
help() {
    "$@" --help 2>&1 | bat --plain --language=help 1>&2
}

# ============================================================
# tmux autostart
# ============================================================
if command -v tmux &>/dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
    exec tmux
fi

# ============================================================
# History search with arrow keys
# ============================================================
autoload -U history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^[[A" history-beginning-search-backward-end
bindkey "^[[B" history-beginning-search-forward-end

# ============================================================
# Other shell integrations
# ============================================================
eval "$(zoxide init zsh)"
eval "$(thefuck --alias)"

# ============================================================
# Aliases
# ============================================================
alias c="code ."
alias lgit="lazygit"
alias cd="z"
alias s="fzf"
alias cat="bat"
alias ls='eza --long --icons --no-user --no-time --hyperlink'
alias tree='eza --tree --icons'
alias tkill='tmux kill-session -t'
alias tls='tmux ls'

# ============================================================
# pyenv
# ============================================================
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - zsh)"
