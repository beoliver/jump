
function _tp() {
    length=${#COMP_WORDS[@]}
    if [[ "${length}" -eq 1 ]]; then
        COMPREPLY=( $(compgen -W "$(tp --list-aliases)" -- "$word") )        
    fi
}

complete -F _tp tp