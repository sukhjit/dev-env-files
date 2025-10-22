export XDG_DATA_HOME=${XDG_DATA_HOME:="$HOME/.local/share"}
export XDG_CACHE_HOME=${XDG_CACHE_HOME:="$HOME/.cache"}
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:="$HOME/.config"}
export XDG_STATE_HOME=${XDG_STATE_HOME:="$HOME/.local/state"}
export XDG_PICTURES_DIR=${XDG_PICTURES_DIR:="$HOME/Pictures"}

export ZDOTDIR=$HOME/.config/zsh
export HISTFILE="$ZDOTDIR/history"
export HISTSIZE=30000
export SAVEHIST=30000

export EDITOR="vim"
export OPENER="xdg-open"
export PAGER="less -FRX"
export TERMINAL="ghostty"
export VIDEO="mpv"
export WM="Hyprland"

export AWS_SHARED_CREDENTIALS_FILE=$XDG_CONFIG_HOME/aws/credentials
export AWS_CONFIG_FILE=$XDG_CONFIG_HOME/aws/config
export CARGO_HOME="$XDG_DATA_HOME"/cargo
export GOPATH=$XDG_DATA_HOME/go
export GOMODCACHE=$XDG_CACHE_HOME/go/mod
export PSQLRC=$XDG_CONFIG_HOME/pg/psqlrc
export PSQL_HISTORY=$XDG_STATE_HOME/psql_history
export PASSWORD_STORE_DIR=$XDG_DATA_HOME/pass
export PYTHON_HISTORY=$XDG_STATE_HOME/python_history

export WGETRC=$XDG_CONFIG_HOME/wgetrc
