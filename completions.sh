
function _jump() {
    COMPREPLY=()
    local word="${COMP_WORDS[COMP_CWORD]}"
    if [ "$COMP_CWORD" -eq 1 ]; then
    COMPREPLY=( $(compgen -W "$(jump --list-aliases)" -- "$word") )    
    fi
}

complete -F _jump jump