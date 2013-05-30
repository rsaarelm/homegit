[[ -s $HOME/.zshrc.local ]] && source "$HOME/.zshrc.local"

alias homegit="GIT_DIR=~/work/homegit GIT_WORK_TREE=~ git"
alias ls="ls --color=auto -lF"
alias arst="setxkbmap us -variant intl"
alias asdf="xset b off;setxkbmap us -variant colemak;xmodmap -e 'remove Control = Control_L' -e 'keycode 66 = Control_L Control_L Control_L Control_L' -e 'keycode 37 = BackSpace BackSpace BackSpace BackSpace' -e 'add Control = Control_L'"

export PATH="$PATH:$HOME/bin"
export EDITOR=vim
export VISUAL=vim

setopt hist_ignore_space

autoload -U colors && colors # Enable colors in prompt
setopt prompt_subst

git_prompt() {
  local git_where="$(timeout 0.1 git name-rev --name-only --no-undefined --always HEAD 2> /dev/null)"
  if [[ ! -n $git_where ]]; then return; fi
  local col="%{$reset_color%}"
  local gits="$(timeout 0.3 git status -unormal 2>&1)"
  if [[ -z $gits ]]; then; col="%{$fg_bold[black]%}" # Timed out
  elif [[ $gits =~ "Untracked files" ]]; then
    if [[ $gits =~ "Changes not staged" ]]; then; col="%{$fg[magenta]%}"
    elif [[ $gits =~ "Changes to be committed" ]]; then; col="%{$fg[cyan]%}"
    else; col="%{$fg[blue]%}"
    fi
  else
    if [[ $gits =~ "Changes not staged" ]]; then; col="%{$fg[yellow]%}"
    elif [[ $gits =~ "Changes to be committed" ]]; then; col="%{$fg[green]%}"
    fi
  fi
  local prompt=
  echo $col"±$git_where%{$reset_color%} "
}

user_color() { if [[ "$EUID" = 0 ]]; then echo "red"; else; echo "green"; fi }

PS1='%{$fg[$(user_color)]%}%~ %#%{$reset_color%} '
RPS1='$(git_prompt)%{$fg[$(user_color)]%}%n@%m%{$reset_color%} %{$fg[cyan]%}%D{%H:%M:%S}%{$reset_color%}'

# Colemak layout friendly vikeys setup
bindkey -M vicmd 'n' vi-backward-char
bindkey -M vicmd 'e' down-line-or-history
bindkey -M vicmd 'E' vi-join
bindkey -M vicmd 'i' up-line-or-history
bindkey -M vicmd 'o' vi-forward-char
bindkey -M vicmd 'h' vi-repeat-search
bindkey -M vicmd 'l' vi-insert
bindkey -M vicmd 'L' vi-insert-bol
bindkey -M vicmd 'k' vi-open-line-below
bindkey -M vicmd 'K' vi-open-line-above
bindkey -M vicmd 'j' vi-forward-word-end

bindkey -M viins 'qk' vi-cmd-mode

is_cygwin() {
    [[ `uname -o` == 'Cygwin' ]]
}

if is_cygwin; then
    # Revert Cygwin's path mangling for P4.
    alias p4='PWD=$(cygpath --windows --absolute .) p4'
fi
