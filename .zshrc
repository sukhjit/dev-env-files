autoload -Uz compinit
compinit

export PATH="$HOME/.local/bin:$PATH"

source $XDG_CONFIG_HOME/zsh/fzf-tab/fzf-tab.plugin.zsh
source $XDG_CONFIG_HOME/zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source $XDG_CONFIG_HOME/zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

eval "$(starship init zsh)"
# Prompt Engineering Starship
PROMPT_NEEDS_NEWLINE=false
precmd() {
  if [[ "$PROMPT_NEEDS_NEWLINE" == true ]]; then
    echo
  fi
  PROMPT_NEEDS_NEWLINE=true
}
clear() {
  PROMPT_NEEDS_NEWLINE=false
  command clear
}

setopt share_history
setopt hist_expire_dups_first
setopt hist_verify
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

bindkey "^[[3~" delete-char
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line

# Jump back or forward one word (Ctrl + Left/Right)
bindkey "^[[1;5D" backward-word
bindkey "^[[1;5C" forward-word

# Fix Home and End keys explicitly inside tmux
bindkey '^[[1~' beginning-of-line
bindkey '^[[4~' end-of-line

# search history key
bindkey "^R" history-incremental-search-backward
# source <(fzf --zsh)

###############################################

alias getsong='yt-dlp -x --audio-format mp3 --audio-quality 0 -o "%(title)s.%(ext)s"'

alias pbcopy='wl-copy'
alias pbpaste='wl-paste'

alias wget='wget --hsts-file="$XDG_CACHE_HOME/wget-hsts"'

alias b64decode='pbpaste | base64 --decode | pbcopy'
alias b64encode='pbpaste | base64 | pbcopy'
alias odcs_decode='pbpaste | base64 --decode | zcat | jq . | pbcopy'
alias odcs_encode='pbpaste | jq -r tostring | tr -d "\n" | gzip -9 | base64 | tr -d "\n" | pbcopy'

alias ll='ls -la --color=auto'

# git alias
alias glog='git log --date-order --pretty="format:%C(yellow)%h%Cblue%d%Creset %s %C(white) %an, %ar%Creset"'
alias gl='git log --oneline'
alias gla='gl --graph --all --oneline'
alias gd='git diff'
alias gdw='gd --color-words'
alias gs='git status'
alias glt='git log --no-walk --tags --oneline'
alias gitWhatChangesMost='git log --format=format: --name-only --since="1 year ago" | sort | uniq -c | sort -nr | head -20'
alias gitWhoBuiltThis='git shortlog -sn --no-merges'
alias gitFixList='git log -i -E --grep="fix|bug|broken" --name-only --format='' | sort | uniq -c | sort -nr | head -20'
alias gitCountByMonth='git log --format='%ad' --date=format:'%Y-%m' | sort | uniq -c'
alias gitRevertFreq='git log --oneline --since="1 year ago" | grep -iE "revert|hotfix|emergency|rollback"'

alias randomGen='openssl rand -base64 8 | md5sum'

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
