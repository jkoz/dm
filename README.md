A collection of fuzzy finder scripts
==============

## Dependencies

- fzf, slmenu, dmenu, etc.
- wmctrl, xdotool
- silver search
- xdg-open
- ctags

## Feature

```sh
> dm -h

Usage:
        dm [options] <command> [command options]
Commands:
        re|recursive    File manager (select only)
        fm|filemgr      File manager (xdg-open)
        fi|find         Find (select only)
        op|open         Find (xdg-open)
        sw|switch       Switch windows
        ps|process      Kill process
        rn|run          Launcher
        tg|tags <file>  Tags
        mn|menu         Shortkeys (sxhkd)
```

## Run in a launcher

- St (preferred)

```sh
st -c Fzf -e sh -c "dm -b fzf ps"
xterm -e "sh -c fzf"
```
- Xterm

```sh
xterm -e "sh -c fzf"
```
