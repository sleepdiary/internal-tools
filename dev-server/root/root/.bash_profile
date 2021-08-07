# enable bash completion in interactive shells
if ! shopt -oq posix; then
 if [ -f /usr/share/bash-completion/bash_completion ]; then
   . /usr/share/bash-completion/bash_completion
 elif [ -f /etc/bash_completion ]; then
   . /etc/bash_completion
 fi
fi

export GIT_PS1_SHOWDIRTYSTATE=1
export PS1='\033[1;32m\w$(__git_ps1 " (%s)")\$ \033[0m'
