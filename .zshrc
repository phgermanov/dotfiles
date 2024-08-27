# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

export USER=$(whoami)
# Path to your oh-my-zsh installation.
export ZSH="/Users/$USER/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(git)

source $ZSH/oh-my-zsh.sh

export EDITOR='nvim'
export GOPATH=~/go
export PATH="$PATH:$GOPATH/bin"

alias k=kubectl
alias q=exit
alias v=nvim
alias cd=z
alias ls="eza -a --icons=always"
alias cat=bat
alias fzf="fzf --height 40% --layout reverse --border"
alias vic="nvim $HOME/.config/nvim"
alias work="cd $HOME/Work"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source <(kubectl completion zsh)
source <(fzf --zsh)

eval "$(zoxide init zsh)"
