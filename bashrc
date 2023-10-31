# .bashrc

# Source global definitions
#-f to check existence of regular file
if [ -f /etc/bashrc ]; then
        #sourcing file in current shell
        . /etc/bashrc
fi

# User specific environment
#if path does not contain the colon-sep dir's, using regex match =~ in [[]]
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi

#exporting path in bashrc results in persistent update for all current/future sessions
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
#checks if dir (-d) ~/.bashrc.d exists
#if true, then for all regular (-f) files, source/include file in current session
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
