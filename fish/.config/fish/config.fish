# Mac용 Fish 설정 (Apple Silicon & Intel 호환)

# 아키텍처 감지 및 Homebrew 경로 설정
switch (uname -m)
case arm64
    set -gx HOMEBREW_PREFIX /opt/homebrew
case '*'
    set -gx HOMEBREW_PREFIX /usr/local
end

# Homebrew 초기화 (가장 먼저!)
if test -x $HOMEBREW_PREFIX/bin/brew
    eval ($HOMEBREW_PREFIX/bin/brew shellenv)
end

# Homebrew curl 라이브러리 경로 (git https 호환성 문제 해결)
if test -d $HOMEBREW_PREFIX/opt/curl/lib
    set -gx DYLD_LIBRARY_PATH $HOMEBREW_PREFIX/opt/curl/lib $DYLD_LIBRARY_PATH
end

# 환경 변수
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx SHELL (which fish)

# Conda 초기화
# >>> conda initialize >>>
if test -f $HOME/miniconda3/bin/conda
    eval $HOME/miniconda3/bin/conda "shell.fish" "hook" $argv | source
else if test -f $HOMEBREW_PREFIX/Caskroom/miniconda/base/bin/conda
    # Homebrew로 설치한 경우
    eval $HOMEBREW_PREFIX/Caskroom/miniconda/base/bin/conda "shell.fish" "hook" $argv | source
end
# <<< conda initialize <<<

# conda 환경 자동 활성화 (필요시 환경명 변경)
# if type -q conda
#     conda activate your_env 2>/dev/null
# end

# PATH 우선순위 조정 (conda 환경을 최우선으로)
if set -q CONDA_PREFIX
    set -l conda_bin $CONDA_PREFIX/bin
    if test -d $conda_bin
        set -l path_without_conda (string match -v $conda_bin $PATH)
        set -gx PATH $conda_bin $path_without_conda
    end
end

# 추가 경로
fish_add_path $HOME/.local/bin

# npm global 경로
fish_add_path $HOME/.npm-global/bin

# opencode
fish_add_path $HOME/.opencode/bin

# greeting 비활성화
set -g fish_greeting

# Local config (tokens, API keys, etc.) - not tracked in git
if test -f $HOME/.config/fish/config.local.fish
    source $HOME/.config/fish/config.local.fish
end

# FZF 설정
set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'

# Aliases
alias v="nvim"
alias vi="nvim"
alias vim="nvim"
alias lg="lazygit"
alias ll="ls -la"
alias la="ls -A"
alias l="ls -CF"

# Git aliases
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gl="git pull"
alias gd="git diff"
alias gb="git branch"
alias gco="git checkout"

# Safety aliases
alias rm="rm -i"
alias cp="cp -i"
alias mv="mv -i"

# Starship prompt
starship init fish | source

# Disable automatic window title setting by fish to prevent conflicts with tmux
function fish_title
end
