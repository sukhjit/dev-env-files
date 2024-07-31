# Enable the subsequent settings only in interactive sessions
case $- in
  *i*) ;;
    *) return;;
esac

# Path to your oh-my-bash installation.
export OSH='/home/sukhjit/.oh-my-bash'

# Set name of the theme to load
OSH_THEME="powerbash10k"

OMB_USE_SUDO=true

# To enable/disable display of Python virtualenv and condaenv
OMB_PROMPT_SHOW_PYTHON_VENV=true  # enable

completions=(
  git
  composer
  ssh
)

aliases=(
  general
)

plugins=(
  git
  bashmarks
)

source "$OSH"/oh-my-bash.sh

alias gs='git status'
alias gd='git diff'
alias gl='git log --oneline'

export LESS='-F -X -R'
