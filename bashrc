# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
        for rc in ~/.bashrc.d/*; do
                if [ -f "$rc" ]; then
                        . "$rc"
                fi
        done
fi

unset rc

module use /home/cc/apps/modulefiles
module use /home/cc/intel/oneapi/modulefiles
module use /home/cc/apps/cesm/modulefiles

ulimit -s unlimited

if [[ -f ~/TP.pem ]]; then
        chmod 0600 ~/.ssh/TP.pem
        cp ~/TP.pem ~/.ssh/TP.pem
        eval `ssh-agent -s`
        ssh-add ~/.ssh/TP.pem
else
        echo "Couldn't find TP pem in home directory"
fi
