#!/usr/bin/bash

DMENU_CONFIG=~/.config/dmenu
DMENU_CACHE=$DMENU_CONFIG/cache
mkdir -p $DMENU_CONFIG
[ ! -e "$DMENU_CACHE" ] && touch $DMENU_CACHE

_usage() {
    printf "\nUsage:\n\tdm [options] <command> [command options]\n"
    printf "Commands:\n"
    printf "\tre|recursive\tFile manager (select only)\n"
    printf "\tfm|filemgr\tFile manager (xdg-open)\n"
    printf "\tfi|find\t\tFind (select only)\n"
    printf "\top|open\t\tFind (xdg-open)\n"
    printf "\tsw|switch\tSwitch windows\n"
    printf "\tps|process\tKill process\n"
    printf "\trn|run\t\tLauncher\n"
    printf "\ttg|tags <file>\tTags\n"
    printf "\tmn|menu\t\tShortkeys (sxhkd)\n"
    printf "\n"
}

# default backend dmenu
#dmenu=('dmenu' '-i' '-l 5')
dmenu=('fzf' '--reverse')

args=$(getopt -q -o b: -l "backend:" -n "$(basename $0)" -- "$@")
test $? -ne 0 && _usage && exit 1
eval set -- "$args"; while true; do
    case "$1" in
        # UGLY HACK: for fzf
        -b|--backend) shift; dmenu=("$1"); shift ;;
        --) shift; break ;;
    esac
done # $@ will store all remaing args

_recursive() {
    test -z $1 && f="." || f="$1"; cd $f
    while test -n "$f"; do
        pat=$(pwd)
        f=$( ls -1la --group-directories-first | tail -n +3 | ${dmenu[*]} | awk '{$1=$2=$3=$4=$5=$6=$7=$8=""; gsub(/^[ \t]+|[ \t]+$/,""); print}')
        test -d "$f" && cd "$f" || { test -f "$f" && echo "${pat}/$f" && unset f; }
    done
}

_find() {
    (tac $DMENU_CACHE; ag --silent -l -g "" $@) | awk '!x[$0]++' | ${dmenu[*]}
}

_doopen() {
    xdg-open "$1" 1>&2> /dev/null
    [ "$?" == "0" ] &&  echo "$1" >> $DMENU_CACHE
}

_filemanager() {
    _doopen "$(_recursive $@)"
}

_open() {
    _doopen "$(_find $@)"
}

_switch() {
    wmctrl -lx | sed -r -e 's/[^@]'$(uname -n)'//' | ${dmenu[*]} | cut -d' ' -f1 | xargs xdotool windowactivate
}

_process() {
    ps -eo pcpu,pid,user,args h | sort -k 1 -r | ${dmenu[*]} | awk '{print $2}' | xargs kill -9 &>/dev/null
}

_tags() {
    ctags -f - --sort=no --excmd=pattern --fields=nKs $@ | ${dmenu[*]}
}

_run() {
    echo $PATH | tr ':' ' ' | xargs find  | ${dmenu[*]} | $SHELL
}

_menu() {
    sed 's/^    //g' ~/.config/sxhkd/sxhkdrc | awk '/^# /{if (x)print x;x="";}{x=(!x)?$0:x", » "$0;}END{print x;}' | column -t -s"," | ${dmenu[*]} | awk -F'»' '{print $3}' | $SHELL
}

_lines() {
    cat -n $@ | ${dmenu[*]}
}

case "$1" in
    re|recursive) shift; _recursive $@;;
    fm|filemanager|filemgr) shift; _filemanager $@;;
    fi|find) shift; _find $@;;
    op|open) shift; _open $@;;
    sw|switch) shift; _switch;;
    ps|process) shift; _process;;
    tg|tags) shift; [ $# -eq 0 ] && _usage || _tags $@;;
    rn|run) shift; _run;;
    mn|menu) shift; _menu;;
    ln|lines) shift; [ $# -eq 0 ] && _usage || _lines $@;;
    *) if [ $# -eq 0 ] ; then { while read -r line; do echo "$line"; done | ${dmenu}; } else _usage; fi ;;
esac
exit $?
