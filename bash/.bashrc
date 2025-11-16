#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return
PS1='[\u@\h \W]\$ '

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=100000
HISTFILESIZE=200000

# add date and time to the history file
HISTTIMEFORMAT="%F %T "

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

export TERM=xterm-256color
export EDITOR=vim

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

#######################################################
# GENERAL ALIAS'S
#######################################################
# To temporarily bypass an alias, we precede the command with a \
# EG: the ls command is aliased, but to use the normal ls command you would type \ls

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls -lah --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

alias dbromey='pgcli -h romeyinc.net -U admin romey'
alias dbupgrade='pgcli -h romeyinc.net -U admin upgrade'
alias grep='grep --color=auto'

# enter ssh key pw for session
alias ssha='eval $(ssh-agent) && ssh-add'

# alias to show the date
alias da='date "+%Y-%m-%d %A %T %Z"'

# Alias's to modified commands
alias cp='cp -i'
alias mv='mv -i'
# alias rm='trash -v'
alias mkdir='mkdir -p'

# alias chmod commands
alias mx='chmod a+x'
alias 000='chmod -R 000'
alias 644='chmod -R 644'
alias 666='chmod -R 666'
alias 755='chmod -R 755'
alias 777='chmod -R 777'

# Search command line history
alias h="history | grep "

# Count all files (recursively) in the current folder
alias countfiles="for t in files links directories; do echo \`find . -type \${t:0:1} | wc -l\` \$t; done 2> /dev/null"

# Alias's to show disk space and space used in a folder
alias diskspace="du -S | sort -n -r |more"
alias folders='du -h --max-depth=1'
alias folderssort='find . -maxdepth 1 -type d -print0 | xargs -0 du -sk | sort -rn'
alias tree='tree -CAhF --dirsfirst'
alias treed='tree -CAFd'
alias mountedinfo='df -hT'

#######################################################
# SPECIAL FUNCTIONS
#######################################################

extract() {
	for archive in "$@"; do
		if [ -f "$archive" ]; then
			case $archive in
			*.tar.bz2) tar xvjf $archive ;;
			*.tar.gz) tar xvzf $archive ;;
			*.bz2) bunzip2 $archive ;;
			*.rar) rar x $archive ;;
			*.gz) gunzip $archive ;;
			*.tar) tar xvf $archive ;;
			*.tbz2) tar xvjf $archive ;;
			*.tgz) tar xvzf $archive ;;
			*.zip) unzip $archive ;;
			*.Z) uncompress $archive ;;
			*.7z) 7z x $archive ;;
			*) echo "don't know how to extract '$archive'..." ;;
			esac
		else
			echo "'$archive' is not a valid file!"
		fi
	done
}

# alias cat to bat
alias cat='bat --paging=never'

# IP address lookup
alias whatismyip="whatsmyip_pro"
# function whatsmyip () {
#     # Internal IP Lookup.
#     if command -v ip &> /dev/null; then
#         echo -n "Internal IP: "
#         ip addr show wlan0 | grep "inet " | awk '{print $2}' | cut -d/ -f1
#     else
#         echo -n "Internal IP: "
#         ifconfig wlan0 | grep "inet " | awk '{print $2}'
#     fi

#     # External IP Lookup
#     echo -n "External IP: "
#     curl -s ifconfig.me
# }

# A more robust IP lookup
function whatsmyip_pro () {
    # Find default interface
    IFACE=$(ip route | grep '^default' | awk '{print $5}' | head -n1)
    if [ -z "$IFACE" ]; then
        echo "Could not determine default network interface."
        return 1
    fi
    echo "Default Interface: $IFACE"

    # Internal IP Lookup
    INTERNAL_IP=$(ip addr show $IFACE | grep "inet " | awk '{print $2}' | cut -d/ -f1)
    echo "Internal IP: $INTERNAL_IP"

    # External IP Lookup
    EXTERNAL_IP=$(curl -s ifconfig.me)
    echo "External IP: $EXTERNAL_IP"
}

# Create a new directory and enter it
function mkcd() {
	mkdir -p "$@" && cd "$@"
}

if [ -f ~/.alias ]; then
  source ~/.alias
fi

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# for postgres MCP
export XTUPLE_DB_HOST="romeyinc.net"     # e.g., "localhost" or IP address
export XTUPLE_DB_PORT="5432"                # Default PostgreSQL port
export XTUPLE_DB_NAME="romey"  # Your xTuple database name
export XTUPLE_DB_USER="admin"       # Database username

# Task Master aliases added on 7/28/2025
alias tm='task-master'
alias taskmaster='task-master'
export PATH=$HOME/.npm-global/bin:$PATH
