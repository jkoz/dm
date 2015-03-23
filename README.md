# Objective

A simple place holder for various dmenu scripts.

# Current feature

- Recursive open files in directory using silver searcher
- File manager based on xdg-open
- Switch windows based on wmctrl and xdotool
- Run command in $PATH, similar with original dmenu_run
- List tags on a given file, used with vim

##  Kill process listed (similar with htop, top)

### Within terminal  

```sh
dm -b fzf ps
```
### In X

```sh
st -c Fzf -e sh -c "dm -b fzf ps"
```


## Run a command defined in sxhkrc

# Dependencies

- dmenu
- wmctrl, xdotool
- silver search
- xdg
- ctags

