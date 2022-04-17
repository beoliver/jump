#!/bin/sh

bold=$(tput bold)
normal=$(tput sgr0)
underline=$(tput smul)
nounderline=$(tput rmul)

help_str="jump - around your filesystem

${bold}SYNOPSIS${normal}

    jump to the directory associated with NAME
    j NAME

    Add a new alias for the current working directory
    j -a [NAME]

    Delete a saved alias NAME
    j NAME -d

    Rename a saved alias NAME to NEW_NAME
    j NAME -r NEW_NAME

${bold}OPTIONS${normal}
    -h (--help)
        Display this help message and exit.
    -a (--add) [${underline}NAME${nounderline}]
        Associate the ${underline}NAME${nounderline} with the current working directory. If no ${underline}NAME${nounderline} is provided then the
        name of the current working directory is used.
    -r (--rename) ${underline}NEW_NAME${nounderline}
        Rename the alias ${underline}NAME${nounderline} to ${underline}NEW_NAME${nounderline}.
    -l (--list-names)
        List all stored alias names.
    -L (--list-all)
        List all stored entires and their associated paths.        
    -d (--delete)
        Delete the NAME and any associated PATH.
    -g (--generated)
        Display the generated functions for your .bash_profile or .zshrc file.
    -p (--purge)
        Remove any alias for a path that is not a directory.
"

help_and_exit () {
  echo help_str
  exit
}

_path_to_script="$(cd "$(dirname "$0")" || exit; pwd -P)/$(basename "$0")"
j_command_str="# The following function can be pasted into your shell profile.
# calling the 'j' command with a single alias name is equivalent to calling
# 'cd' on the path asociated with the alias.

j () {
  _jump_result=\"\$($_path_to_script \"\${@}\")\"
  if [ \"\${#}\" -eq 1 ]; then
    if case \${1} in -*) false;; *) true;; esac; then
      cd \"\$_jump_result\" && return
    fi
  fi
  echo \"\$_jump_result\"
}

_jump_completions() {
  COMPREPLY=()
  local word=\"\${COMP_WORDS[COMP_CWORD]}\"
  if [ \"\$COMP_CWORD\" -eq 1 ]; then
    COMPREPLY=(\$(compgen -W \"\$($_path_to_script --list-names)\" -- \"\$word\"))
  fi
}

complete -F _jump_completions j
"

# -----------------------------------------------------------------------------
# Entry point 
# -----------------------------------------------------------------------------

JUMP_CONFIG_DIR="$HOME/.config/jump"
DB="$JUMP_CONFIG_DIR/jump.db"

# -----------------------------------------------------------------------------
# check that JUMP_CONFIG_DIR exists

if [ ! -d "$JUMP_CONFIG_DIR" ]; then
  echo "Create '$JUMP_CONFIG_DIR' [y/N]"
  read -r confirmation
  if [ "$confirmation" = "y" ]; then
    mkdir -p "$JUMP_CONFIG_DIR"
    sqlite3 -line "${DB}" \
      "CREATE TABLE aliases(name TEXT NOT NULL PRIMARY KEY, path TEXT NOT NULL);"
    echo "$j_command_str"
    exit
  else
    exit
  fi
fi

# -----------------------------------------------------------------------------

if [ "${#}" -eq 0 ]; then
  # input has length 0
  # this indiecates that it is a `jump` command.
  # we are friendly and list all stored alias/path pairs
  sqlite3 -column "${DB}" "SELECT * FROM aliases;"
  exit
fi

case "$1" in
  -*) # argument is a flag... 
    ;;
  *)
    NAME=$1
    shift
    if [ "${#}" -eq 0 ]; then 
      DIR=$(sqlite3 -list "${DB}" "SELECT path FROM aliases WHERE name='${NAME}';")
      if [ -n "${DIR}" ]; then
        echo "${DIR}"
      fi
      exit
    fi
    ;; 
esac

case $1 in
  -h | --help)
    help_and_exit
    ;;
  -l | --list-names)
    sqlite3 -column "${DB}" "SELECT name FROM aliases;"
    ;;
  -L | --list-all)
    sqlite3 -column "${DB}" "SELECT * FROM aliases;"
    ;;
  -g | --generate)
    echo "$j_command_str"
    ;;      
  -d | --delete)
    sqlite3 -column "${DB}" "DELETE FROM aliases WHERE name='${NAME}';"
    ;;
  -p | --purge)
    sqlite3 -column "${DB}" "SELECT path FROM aliases;" | while read -r path ; do
      if [ ! -d "$path" ]; then
        sqlite3 "${DB}" "DELETE FROM aliases WHERE path='${path}';"
      fi
    done
    ;;
  -r | --rename)
    if [ -z "$NAME" ]; then
      help_and_exit
    fi
    NEW_NAME=$2
    if [ -z "$NEW_NAME" ]; then
      help_and_exit
    fi
    sqlite3 -column "${DB}" \
      "UPDATE aliases SET name='${NEW_NAME}' WHERE name='${NAME}';"
    ;;
  -a | --add)
    if [ -n "$NAME" ]; then
      help_and_exit
    fi
    DIR=$(pwd)
    NAME=${2:-$(basename "$DIR")}  
    sqlite3 "${DB}" "INSERT INTO aliases VALUES ('${NAME}', '${DIR}');"
    echo "Added alias name '${NAME}' for path '${DIR}'"
    ;;
  *)
    ;;
esac

exit