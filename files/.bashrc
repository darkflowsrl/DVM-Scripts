# ~/.bashrc: executed by bash(1) for non-login shells.

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

export PATH="$HOME/scripts:$PATH"
export EDITOR=/usr/bin/vi

# Inicializo el can bus con un tasa de bits de 250000
sleep 5
for i in {1..10}
do
  ip link set can0 up type can bitrate 250000
done

# Limpio los backups
./root/scripts/clean.sh

# Inicializo el backend
nohup python3 /root/backend/main.py

# Inicializo el frontend en modo kisoko
startx /root/frontend/app.AppImage --no-sandbox -- -nocursor