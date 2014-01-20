# MCP Control Prompt (MCP) - See all the things!
# -- because I'm not cool enough to use only $ or # effectively
#
# Copy, right? 2014 Jeremy Price - @jermops 
#
# v1.0  

PROD_HOST_TRIGGER='prod'
PROD_HOST_COLOR=31
NORMAL_HOST_COLOR=33

ALERT_USER_NAME='root'
ALERT_USER_COLOR=31
NORMAL_USER_COLOR=32


# Activate git completion and prompt functions. My Linux has these built-in in
# /etc/bash_completion.d/git
# On OSX I'm using homebrew where they can be found as below.
if [ $(uname) = "Darwin" ]; then
  source /usr/local/git/contrib/completion/git-prompt.sh
  source /usr/local/git/contrib/completion/git-completion.bash
fi 


# Jeremy's boto and aws cli config unifyer/switcher
cb(){
    set_default_boto(){
        unset BOTO_CONFIG
        unset BOTO_DISPLAYENV
        export AWS_CONFIG_FILE=~/.boto
        echo "Using default .boto"
    }
    #Change boto env
    unset found
    BOTO_SEARCHENV=$1
    if [ -n "$BOTO_SEARCHENV" ]; then
        BOTO_SUFFIX="-$BOTO_SEARCHENV"
    else
        #Using default .boto... hopefully it exists"
        set_default_boto
        return 0
    fi
    # I one point ran into a scanario where it made sense to have .boto files
    # within project folders... maybe it was before i made this script. At any
    # rate, we support .boto files within the current folder and your $HOME
    # folder, in that order.
    for path in `pwd` $HOME
    do
        if [ -e "$path/.boto$BOTO_SUFFIX" ]; then
            export BOTO_DISPLAYENV=${BOTO_SEARCHENV:-default}
            export BOTO_CONFIG=$path/.boto$BOTO_SUFFIX
            export AWS_CONFIG_FILE=$path/.boto$BOTO_SUFFIX
            echo "Using $path/.boto$BOTO_SUFFIX"
            found=1
            break
        fi
    done
    if [ -z "$found" ]; then
        echo "#WARN: .boto$BOTO_SUFFIX not found. Not changing anything"
    fi
}
#functinon to allow dynamic boto env in prompt
_boto_env(){
    if [ -n "$BOTO_DISPLAYENV" ]; then
        echo "aws-$BOTO_DISPLAYENV"
    else
        echo -n "aws-default"
    fi
}
#Jeremy's time-telling, response-code watching, boto-env telling, git-laden, path showinge shell prompt

case "$TERM" in
    xterm*|rxvt*|screen*|linux)
        # Decide username and servername colors
        if [[ "`hostname`" =~ $PROD_HOST_TRIGGER ]]; then HCOLOR=$PROD_HOST_COLOR; else HCOLOR=$NORMAL_HOST_COLOR; fi
        if [[ "$USER" =~ "$ALERT_USER_NAME" ]]; then UCOLOR=$ALERT_USER_COLOR; else UCOLOR=$NORMAL_USER_COLOR; fi
        
        #Set up the bottom line with user@host:commandnum:$path
        PS1='\[\033[01;${UCOLOR}m\]\u@\[\033[01;${HCOLOR}m\]\h\[\033[00m\]:\!:\[\033[00m\]\$ '
        
        #Populate the iTerm, Xterm, Eterm, etc... tab/title bar with current user and hostname
        PS1="\[\e]0;\u@\h: \w\a\]$PS1"
        
        # If we're using screen a compatible terminal, populate current tab
        # with hostname
        [[ $TERM =~ "screen" ]] && export PS1="\[\033k\033\134\033k\h\033\134\]$PS1"
        
        # Add the top line with time, boto/aws env, path, git status, 
        # oh and make it red if the last command's return code is non-zero
        PS1="\`if [[ \$? = "0" ]]; then echo "\\[\\033[37m\\]"; else echo "\\[\\033[31m\\]"; fi\`[\T]:\`_boto_env\`:\[\033[00;36m\]\w"'$(__git_ps1 " (git:%s)")\n'"$PS1"
        ;;
    *)
        ;;
esac

complete -C aws_completer aws
alias crontab='crontab -i'
shopt -s histappend
BASH_ENV="$HOME/.bashrc"
