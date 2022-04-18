# jump

**j**(ump) around your filesystem.

This is a simple program (it's just a shell script) that lets you associate directory paths with memorable names. You can then use these names to quickly change directory.

Add an alias using the `-a` flag.
```
j -a <alias>
```
Type the alias to change directory. 
```
j <alias>
```

# installation

1. Download the `jump.sh` script.
2. Run the command `jump.sh`.

This will create a directory `$HOME/.config/jump` that will contain a sqlite database file used to store the aliases and paths.

A function will be printed to stdout that can be pasted into your `.bash_profile` or similar.

```
$ ./jump.sh
Create '/Users/beoliver/.config/jump' [y/N]
y
# The following function can be pasted into your shell profile.
# calling the 'j' command with a single alias name is equivalent to calling
# 'cd' on the path asociated with the alias.

j () {
  _jump_result="$(/Users/beoliver/dev/beoliver/jump/jump.sh ${@})"
  if [ ${#} -eq 1 ]; then
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
    COMPREPLY=($(compgen -W "$(/Users/beoliver/dev/beoliver/jump/jump.sh --list-names)" -- "$word"))
  fi
}

complete -F _jump_completions j
```