# jump

**jump** around your filesystem.

`jump` lets you associate directory paths with names. You can then use these names to quickly change directory. The `jump` command (`j`) is similar to adding aliases to you `.bash_profile`/`.zshrc` files.

```sh
alias name="cd ${PATH_TO_DIR}"
```

Unlike using the `alias` keyword in your bash/zsh profile, `jump` lets you avoid having to source you profile after adding an alias. It is also possible to use alias names that you otherwise conflict with existing applications.

# installation

1. Download the `jump.sh` script.
2. Run the command `jump.sh`.

This will (if the user consents) create a directory `$HOME/.config/jump` that will contain a sqlite database file `jump.db`. and a `completions.sh` script.

A function will be printed to stdout that can be pasted into your `.bash_profile`/`.zshrc` file.



```sh 
# The following function can be pasted into your shell profile.
# calling the 'j' command with a single alias name is equivalent to calling
# 'cd' on the path asociated with the alias.

j () {
  _jump_result="$(/Users/beoliver/dev/beoliver/jump/jump "${@}")"
  if [ "${#}" -eq 1 ]; then
    if case ${1} in -*) false;; *) true;; esac; then
      cd "$_jump_result" && return
    fi
  fi
  echo "$_jump_result"
}

_jump_completions() {
  COMPREPLY=()
  local word="${COMP_WORDS[COMP_CWORD]}"
  if [ "$COMP_CWORD" -eq 1 ]; then
    COMPREPLY=($(compgen -W "$(/Users/beoliver/dev/beoliver/jump/jump --list-names)" -- "$word"))
  fi
}

complete -F _jump_completions j
```