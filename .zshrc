# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="sukhjit"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git)
source $ZSH/oh-my-zsh.sh
source ~/.p10k.zsh

# custom scripts
[[ -d $XDG_CONFIG_HOME/custom-scripts ]] && export PATH="$PATH:$XDG_CONFIG_HOME/custom-scripts"

# powerlevel10k settings
setopt share_history
setopt hist_expire_dups_first
setopt hist_verify
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

bindkey "^[[A" history-search-backward
bindkey "^[[B" history-search-forward
# bind Home and End keys for tmux
bindkey "\E[1~" beginning-of-line
bindkey "\E[4~" end-of-line

###############################################

alias pbcopy='wl-copy'
alias pbpaste='wl-paste'

alias wget='wget --hsts-file="$XDG_CACHE_HOME/wget-hsts"'

alias odcs_decode='pbpaste | base64 --decode | zcat | jq . | pbcopy'
alias odcs_encode='pbpaste | jq -r tostring | tr -d "\n" | gzip -9 | base64 | tr -d "\n" | pbcopy'

alias ll='ls -la'

alias glog='git log --date-order --pretty="format:%C(yellow)%h%Cblue%d%Creset %s %C(white) %an, %ar%Creset"'
alias gl='git log --oneline'
alias gla='gl --graph --all --oneline'
alias gd='git diff'
alias gdw='gd --color-words'
alias gs='git status'
alias glt='git log --no-walk --tags --oneline'

alias randomGen='openssl rand -base64 8 | md5'
alias curlAk="curl -H \"Pragma: \
    akamai-x-cache-on, \
    akamai-x-cache-remote-on, \
    akamai-x-check-cacheable, \
    akamai-x-get-cache-key, \
    akamai-x-get-extracted-values, \
    akamai-x-get-nonces, \
    akamai-x-get-ssl-client-session-id, \
    akamai-x-get-true-cache-key, \
    akamai-x-serial-no\""

# custom config
source ~/.my-custom-zsh.sh
