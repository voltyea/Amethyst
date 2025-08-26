if status is-interactive
    # Commands to run in interactive sessions can go here
    and not set -q TMUX
    and command -q tmux
    tmux attach || tmux new
end

function fish_greeting
end

# rustup shell setup
if not contains "$HOME/.cargo/bin" $PATH
    # Prepending path in case a system-installed rustc needs to be overridden
    set -x PATH "$HOME/.cargo/bin" $PATH
end

set -Ux EDITOR nvim
# fzf catppuccin theme
set -Ux FZF_DEFAULT_OPTS "\
--color=fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC \
--color=marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8 \
--color=selected-bg:#45475A \
--color=border:#313244,label:#CDD6F4"
alias vim nvim
alias cl clear
oh-my-posh init fish --config $HOME/.config/ohmyposh.toml | source
pokego --no-title --random 1-8
zoxide init --cmd cd fish | source
fzf --fish | source

fish_add_path $HOME/.spicetify/
