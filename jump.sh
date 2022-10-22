#!/bin/sh

set -o nounset
set -o errexit

_path_to_script="$(cd "$(dirname "$0")" || exit; pwd -P)/$(basename "$0")"

bold=$(tput bold)
normal=$(tput sgr0)
underline=$(tput smul)
nounderline=$(tput rmul)

help_str="j(ump) around your filesystem with tab completion...

${bold}SYNOPSIS${normal}

    j [NAME] [OPTION] ...

${bold}OPTIONS${normal}
    -a (--add)
        Associate the ${underline}NAME${nounderline} with the current working directory. 
        If no ${underline}NAME${nounderline} is provided then the name of the current 
        working directory is used.
    -d (--delete)
        Delete ${underline}NAME${nounderline} and any associated PATH.
    -r (--rename) ${underline}NEW_NAME${nounderline}
        Rename ${underline}NAME${nounderline} to ${underline}NEW_NAME${nounderline}.
    -l (--list)
        List all stored aliases and their paths.
    -g (--generated)
        Display the generated functions for your .bash_profile.
    -p (--purge)
        Remove any alias for a path that is not a directory.
    -h (--help)
        Display this help message and exit.

${bold}EXAMPLES${normal}

    List all stored aliases:
    j

    Jump to the directory associated with ${underline}NAME${nounderline}:
    j ${underline}NAME${nounderline}

    Create an alias for the current working directory using its basename:
    j -a

    Associate ${underline}NAME${nounderline} with the current working directory:
    j ${underline}NAME${nounderline} -a

    Delete a saved alias ${underline}NAME${nounderline}:
    j ${underline}NAME${nounderline} -d

    Rename a saved alias ${underline}NAME${nounderline} to ${underline}NEW_NAME${nounderline}:
    j ${underline}NAME${nounderline} -r ${underline}NEW_NAME${nounderline}

"

help_and_exit () {
  echo "$help_str"
  exit
}

j_command_str="# The following function can be pasted into your shell profile.
# calling the 'j' command with a single alias name is equivalent to calling
# 'cd' on the path asociated with the alias.

j () {
  _jump_result=\"\$($_path_to_script \${@})\"
  if [ \${#} -eq 1 ]; then
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
    COMPREPLY=(\$(compgen -W \"\$($_path_to_script)\" -- \"\$word\"))
  fi
}

complete -F _jump_completions j
"

# -----------------------------------------------------------------------------
# Entry point 
# -----------------------------------------------------------------------------

jump_config_dir="$HOME/.config/jump"
jump_db="${jump_config_dir}/jump.db"

# -----------------------------------------------------------------------------

if [ ! -d "${jump_config_dir}" ]; then
  echo "Create '${jump_config_dir}' [y/N]"
  read -r confirmation
  if [ "$confirmation" = "y" ]; then
    mkdir -p "${jump_config_dir}"
    sqlite3 -line "${jump_db}" \
      "CREATE TABLE aliases(name TEXT NOT NULL PRIMARY KEY, path TEXT NOT NULL);"
    echo "$j_command_str"
  fi
  exit
fi

# -----------------------------------------------------------------------------

if [ ${#} -eq 0 ]; then
  # We intrepret no args as a `jump` command. Just display all aliases...
  sqlite3 -column "${jump_db}" "SELECT name FROM aliases;"
  exit
fi

if case $1 in -*) false;; *) true;; esac; then
  # first argument did not begin with a '-' prefix
  # set alias_name to the first argument
  alias_name=$1
  shift
fi

if [ ${#} -eq 0 ]; then 
  # if no more args are present then just find the path for the 'alias_name'
  alias_path=$(sqlite3 -list "${jump_db}" "SELECT path FROM aliases WHERE name='${alias_name}';")
  if [ -n "${alias_path}" ]; then
    echo "${alias_path}"
  fi
  exit
fi

case $1 in
  -a | --add)
    curr_dir=$(pwd)
    alias_name=${alias_name:-$(basename "$curr_dir")}  
    sqlite3 "${jump_db}" "INSERT INTO aliases VALUES ('${alias_name}', '${curr_dir}');"
    echo "Added alias name '${alias_name}' for path '${curr_dir}'"
    ;;
  -d | --delete)
    if [ -z "${alias_name}" ]; then
      help_and_exit
    fi  
    sqlite3 -column "${jump_db}" "DELETE FROM aliases WHERE name='${alias_name}';"
    ;;
  -r | --rename)
    if [ -z "${alias_name}" ]; then
      help_and_exit
    fi
    new_alias_name=$2
    if [ -z "${new_alias_name}" ]; then
      help_and_exit
    fi
    sqlite3 -column "${jump_db}" \
      "UPDATE aliases SET name='${new_alias_name}' WHERE name='${alias_name}';"
    ;;
  -p | --purge)
    sqlite3 -column "${jump_db}" "SELECT path FROM aliases;" | while read -r path ; do
      if [ ! -d "$path" ]; then
        sqlite3 "${jump_db}" "DELETE FROM aliases WHERE path='${path}';"
      fi
    done
    ;;
  -l | --list)
      sqlite3 -column "${jump_db}" "SELECT * FROM aliases;"
    ;;
  -g | --generate)
    echo "$j_command_str"
    ;;
  -h | --help)
    help_and_exit
    ;;
  *)
    help_and_exit
    ;;
esac

exit 
