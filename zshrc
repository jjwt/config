
# Var
PL="2"




# Alias
alias dir='dir -1'
alias ls='ls --color=auto'
alias la='ls -AF'
alias ll='ls -lF'
alias lla='ls -AlF'
alias grep='grep --color=auto'
alias sudo='sudo '
alias pacman='pacman --color=auto'
alias w3m='w3m -cookie'
alias minicom="minicom -c on"




# Export
export TIME_STYLE="+%Y-%m-%d %H:%M:%S"
export GCC_COLORS="error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01"




# Command completion
setopt AUTO_LIST
setopt AUTO_MENU
setopt MENU_COMPLETE
autoload -U compinit
compinit




# Color
autoload -U colors
colors
eval `dircolors ~/.colors`




# PROMPT

autoload -U promptinit
promptinit
setopt prompt_subst

XB_FACE="(^_^)"

X_FACE="%{$fg_bold[white]%}$XB_FACE%{$reset_color%}"
X_URNM="%{$fg_bold[red]%}%n%{$reset_color%}"
X_MCNM="%{$fg_bold[cyan]%}%M%{$reset_color%}"
X_CLON="%{$fg_bold[white]%}:%{$reset_color%}"
X_PATH="%{$fg_bold[green]%}%~%{$reset_color%}"
X_NTLN="%{$fg_bold[yellow]%}==>%{$reset_color%}"
X_NTMD="%{$fg_bold[yellow]%}=>%{$reset_color%}"
X_NTST="%{$fg_bold[yellow]%}>%{$reset_color%}"
X_TIME="%{$fg_no_bold[magenta]%}20%D %*%{$reset_color%}"


if [[ $PL == "2" ]]; then

  git_info() {
    local gitrev="$(git rev-parse --git-dir 2>/dev/null)"
    if [[ "$gitrev" == "" ]]; then
      echo ""
    else
      local git_cmt="$(git reflog 2>/dev/null | sed -n '1p' | awk '{print $1}')"
      local git_brc="$(git branch 2>/dev/null | grep '^\*' | sed 's/^\*\ //')"
      echo "%{$fg_bold[blue]%}($git_brc:$git_cmt)%{$reset_color%}"
    fi
  }

  mid_space() {
    local len
    (( len = ${COLUMNS} - ${#${(%):-.$XB_FACE %n@%M:%~20%D %*}} ))
    printf " "%.0s {1..$len}
  }

  PROMPT="$X_FACE $X_URNM@$X_MCNM$X_CLON $X_PATH  \$(git_info)
 $X_NTLN "
  PROMPT2="   $X_NTST "
  RPROMPT=$X_TIME

else

  PROMPT="$X_FACE$X_PATH $X_NTMD "
  PROMPT2=" $X_NTST "
  RPROMPT=$X_TIME

fi




# History
export HISTFILE=~/.zsh_history
export HISTSIZE=10000
export SAVEHIST=10000




## the part of completion system is from Archlinux /etc/zsh/zshrc

# prepare for completion system

is4(){
    [[ $ZSH_VERSION == <4->* ]] && return 0
    return 1
}

is42(){
    [[ $ZSH_VERSION == 4.<2->* || $ZSH_VERSION == <5->* ]] && return 0
    return 1
}

# completion system
#
# called later (via is4 && grmlcomp)
# note: use 'zstyle' for getting current settings
#         press ^xh (control-x h) for getting tags in context; ^x? (control-x ?) to run complete_debug with trace output
grmlcomp() {
    # TODO: This could use some additional information

    # Make sure the completion system is initialised
    (( ${+_comps} )) || return 1

    # allow one error for every three characters typed in approximate completer
    zstyle ':completion:*:approximate:'    max-errors 'reply=( $((($#PREFIX+$#SUFFIX)/3 )) numeric )'

    # don't complete backup files as executables
    zstyle ':completion:*:complete:-command-::commands' ignored-patterns '(aptitude-*|*\~)'

    # start menu completion only if it could find no unambiguous initial string
    zstyle ':completion:*:correct:*'       insert-unambiguous true
    zstyle ':completion:*:corrections'     format $'%{\e[0;31m%}%d (errors: %e)%{\e[0m%}'
    zstyle ':completion:*:correct:*'       original true

    # activate color-completion
    zstyle ':completion:*:default'         list-colors ${(s.:.)LS_COLORS}

    # format on completion
    zstyle ':completion:*:descriptions'    format $'%{\e[0;31m%}completing %B%d%b%{\e[0m%}'

    # automatically complete 'cd -<tab>' and 'cd -<ctrl-d>' with menu
    # zstyle ':completion:*:*:cd:*:directory-stack' menu yes select

    # insert all expansions for expand completer
    zstyle ':completion:*:expand:*'        tag-order all-expansions
    zstyle ':completion:*:history-words'   list false

    # activate menu
    zstyle ':completion:*:history-words'   menu yes

    # ignore duplicate entries
    zstyle ':completion:*:history-words'   remove-all-dups yes
    zstyle ':completion:*:history-words'   stop yes

    # match uppercase from lowercase
    zstyle ':completion:*'                 matcher-list 'm:{a-z}={A-Z}'

    # separate matches into groups
    zstyle ':completion:*:matches'         group 'yes'
    zstyle ':completion:*'                 group-name ''

    if [[ "$NOMENU" -eq 0 ]] ; then
        # if there are more than 5 options allow selecting from a menu
        zstyle ':completion:*'               menu select=5
    else
        # don't use any menus at all
        setopt no_auto_menu
    fi

    zstyle ':completion:*:messages'        format '%d'
    zstyle ':completion:*:options'         auto-description '%d'

    # describe options in full
    zstyle ':completion:*:options'         description 'yes'

    # on processes completion complete all user processes
    zstyle ':completion:*:processes'       command 'ps -au$USER'

    # offer indexes before parameters in subscripts
    zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters

    # provide verbose completion information
    zstyle ':completion:*'                 verbose true

    # recent (as of Dec 2007) zsh versions are able to provide descriptions
    # for commands (read: 1st word in the line) that it will list for the user
    # to choose from. The following disables that, because it's not exactly fast.
    zstyle ':completion:*:-command-:*:'    verbose false

    # set format for warnings
    zstyle ':completion:*:warnings'        format $'%{\e[0;31m%}No matches for:%{\e[0m%} %d'

    # define files to ignore for zcompile
    zstyle ':completion:*:*:zcompile:*'    ignored-patterns '(*~|*.zwc)'
    zstyle ':completion:correct:'          prompt 'correct to: %e'

    # Ignore completion functions for commands you don't have:
    zstyle ':completion::(^approximate*):*:functions' ignored-patterns '_*'

    # Provide more processes in completion of programs like killall:
    zstyle ':completion:*:processes-names' command 'ps c -u ${USER} -o command | uniq'

    # complete manual by their section
    zstyle ':completion:*:manuals'    separate-sections true
    zstyle ':completion:*:manuals.*'  insert-sections   true
    zstyle ':completion:*:man:*'      menu yes select

    # Search path for sudo completion
    zstyle ':completion:*:sudo:*' command-path /usr/local/sbin \
                                               /usr/local/bin  \
                                               /usr/sbin       \
                                               /usr/bin        \
                                               /sbin           \
                                               /bin            \
                                               /usr/X11R6/bin

    # provide .. as a completion
    zstyle ':completion:*' special-dirs ..

    # run rehash on completion so new installed program are found automatically:
    _force_rehash() {
        (( CURRENT == 1 )) && rehash
        return 1
    }

    ## correction
    # some people don't like the automatic correction - so run 'NOCOR=1 zsh' to deactivate it
    if [[ "$NOCOR" -gt 0 ]] ; then
        zstyle ':completion:*' completer _oldlist _expand _force_rehash _complete _files _ignored
        setopt nocorrect
    else
        # try to be smart about when to use what completer...
        setopt correct
        zstyle -e ':completion:*' completer '
            if [[ $_last_try != "$HISTNO$BUFFER$CURSOR" ]] ; then
                _last_try="$HISTNO$BUFFER$CURSOR"
                reply=(_complete _match _ignored _prefix _files)
            else
                if [[ $words[1] == (rm|mv) ]] ; then
                    reply=(_complete _files)
                else
                    reply=(_oldlist _expand _force_rehash _complete _ignored _correct _approximate _files)
                fi
            fi'
    fi

    # command for process lists, the local web server details and host completion
    zstyle ':completion:*:urls' local 'www' '/var/www/' 'public_html'

    # caching
    [[ -d $ZSHDIR/cache ]] && zstyle ':completion:*' use-cache yes && \
                            zstyle ':completion::complete:*' cache-path $ZSHDIR/cache/

    # host completion
    if is42 ; then
        [[ -r ~/.ssh/known_hosts ]] && _ssh_hosts=(${${${${(f)"$(<$HOME/.ssh/known_hosts)"}:#[\|]*}%%\ *}%%,*}) || _ssh_hosts=()
        [[ -r /etc/hosts ]] && : ${(A)_etc_hosts:=${(s: :)${(ps:\t:)${${(f)~~"$(</etc/hosts)"}%%\#*}##[:blank:]#[^[:blank:]]#}}} || _etc_hosts=()
    else
        _ssh_hosts=()
        _etc_hosts=()
    fi
    hosts=(
        $(hostname)
        "$_ssh_hosts[@]"
        "$_etc_hosts[@]"
        localhost
    )
    zstyle ':completion:*:hosts' hosts $hosts
    # TODO: so, why is this here?
    #  zstyle '*' hosts $hosts

    # use generic completion system for programs not yet defined; (_gnu_generic works
    # with commands that provide a --help option with "standard" gnu-like output.)
    for compcom in cp deborphan df feh fetchipac head hnb ipacsum mv \
                   pal stow tail uname ; do
        [[ -z ${_comps[$compcom]} ]] && compdef _gnu_generic ${compcom}
    done; unset compcom

    # see upgrade function in this file
    compdef _hosts upgrade
}

is4    && grmlcomp


