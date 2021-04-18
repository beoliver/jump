
function _tp() {
    COMPREPLY=()
    local word="${COMP_WORDS[COMP_CWORD]}"
    if [ "$COMP_CWORD" -eq 1 ]; then
    COMPREPLY=( $(compgen -W "$(tp --list-aliases)" -- "$word") )    
    fi
}

complete -F _tp tp