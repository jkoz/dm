#!/usr/bin/bash

DMENU_CONFIG=~/.config/dmenu
DMENU_CACHE=$DMENU_CONFIG/cache
mkdir -p $DMENU_CONFIG
[ ! -e "$DMENU_CACHE" ] && touch $DMENU_CACHE

dmenu=('dmenu' '-i' '-l 5')

_usage() {
    printf "\nUsage:\n\tdmenu [options] <command> [command options]\n"
    printf "Commands:\n"
    printf "\tre|recursive\trecursive list directory\n"
    printf "\tfm|filemgr\tfile manager\n"
    printf "\tfi|find\t\trecusive find current directoru\n"
    printf "\top|open\t\trecusive find current directoru and open it\n"
    printf "\tsw|switch\tswitch windows\n"
    printf "\tps|process\tlist current process and kill it\n"
    printf "\trn|run\t\tdmenu_run\n"
    printf "\ttg|tags\t\ttags file\n"
    printf "\tmn|menu\t\tmenu shortkeys\n"
    printf "\n"
}

_recursive() {
    test -z $1 && f="." || f="$1"; cd $f
    while test -n "$f"; do
        pat=$(pwd)
        f=$( ls -1la --group-directories-first | tail -n +3 | ${dmenu[*]} -p "$pat" | awk '{$1=$2=$3=$4=$5=$6=$7=$8=""; gsub(/^[ \t]+|[ \t]+$/,""); print}')
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
    dmenu_path | ${dmenu[*]} | ${SHELL:-"/usr/bin/sh"} &
}

_menu() {
    eval "$(sed 's/^    //g' ~/.config/sxhkd/sxhkdrc | awk '/^# /{if (x)print x;x="";}{x=(!x)?$0:x", » "$0;}END{print x;}' | column -t -s"," | ${dmenu[*]} | awk -F'»' '{print $3}')" &
}

case "$1" in
    re|recursive) shift; _recursive $@;;
    fm|filemanager|filemgr) shift; _filemanager $@;;
    fi|find) shift; dmenu+=("-p Find: "); _find $@;;
    op|open) shift; dmenu+=("-p Open: "); _open $@;;
    sw|switch) shift; dmenu+=("-p Switch: "); _switch;;
    ps|process) shift; dmenu+=("-p Process: "); _process;;
    tg|tags) shift; dmenu+=("-p Tags: "); [ $# -eq 0 ] && _usage || _tags $@;;
    rn|run) shift; dmenu+=("-p Run: "); _run;;
    mn|menu) shift; dmenu+=("-p Menu: "); _menu;;
    *) if [ $# -eq 0 ] ; then { while read -r line; do echo "$line"; done | ${dmenu}; } else _usage; fi ;;
esac
exit $?
