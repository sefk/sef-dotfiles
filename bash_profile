#export PROMPT_COMMAND='pwd > /tmp/cwd.`ps -o tty= -p $$`'
# export PATH=\
#	 $PATH:\
#	 /opt/local/bin:\
#	 /opt/local/sbin:\
#	 /usr/local/git/bin:\
#	 /usr/local/maven/bin:\
#	 ~/bin

export PATH=$PATH:/usr/local/bin:/usr/local/sbin:/usr/local/maven/bin:~/pub-src/htty/bin:~/bin:/usr/local/mysql/bin

set -o vi

if [ -e ~/.alias ]; then
  . ~/.bash_alias
fi

if [ -e ~/.bash_secret ]; then
  . ~/.bash_secret
fi

# export CLICOLOR='true'
# export LSCOLORS="gxfxcxdxbxegedabagacad"

# Default PS1
# export PS1="\h:\W \u\$"

# Colored PS1
# export PS1="\[\e[32m\]\u@\h:\W> \[\e[0m\]"
# same as above, but bolded
export PS1="\[\e[32;1m\]\u@\h:\W> \[\e[0m\]"

# autojump is cool!
which brew 1>/dev/null 2>/dev/null
if [ $? -eq 0 ]; then
    if [ -f `brew --prefix`/etc/autojump ]; then
    . `brew --prefix`/etc/autojump
    fi
fi

# setup EC2
if [ -d ~/.ec2 ]; then
    export EC2_HOME=~/.ec2
    export PATH=$PATH:$EC2_HOME/bin
    export EC2_PRIVATE_KEY=`ls $EC2_HOME/sef-ning-east.pem`
    # export EC2_CERT=`ls $EC2_HOME/cert-*.pem`
fi

# Java Dev
export JAVA_HOME=/System/Library/Frameworks/JavaVM.framework/Home/
export MAVEN_OPTS='-Xmx1024m -XX:MaxPermSize=256m'

#
# GIT SUPPORT
#
if [ -f .git-completion.bash ]; then
    . .git-completion.bash
    # export PS1='[\u@\h \W$(__git_ps1 " (%s)")]\$ '       # kind of vanilla
    export PS1='\[\033[01;32m\]\u@\h\[\033[00m\] \[\033[01;34m\]\w\[\033[00m\]$(__git_ps1 "\[\033[01;33m\](%s)\[\033[00m\]")$ '         # more colorful
    # export PS1='\[\033[41;1;37m\]\u@\h:\[\033[40;1;33m\]\W$(__git_ps1 " (%s)")>\[\033[0m\] '  # Butt-ugly IMHO, but YMMV
fi
