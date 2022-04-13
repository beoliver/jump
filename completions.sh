
function _jump() {
    COMPREPLY=()
    local word="${COMP_WORDS[COMP_CWORD]}"
    if [ "$COMP_CWORD" -eq 1 ]; then
    COMPREPLY=( $(compgen -W "$("$JUMP_DIR"/jump -l)" -- "$word") )    
    fi
}

complete -F _jump j
