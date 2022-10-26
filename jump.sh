#!/bin/sh

set -o nounset
set -o errexit

_path_to_script="$(cd "$(dirname "$0")" || exit; pwd -P)/$(basename "$0")"

bold=$(tput bold)
normal=$(tput sgr0)
underline=$(tput smul)
nounderline=$(tput rmul)

help_str="j(ump) around your filesystem...

${bold}SYNOPSIS${normal}

    jump [NAME] [OPTION [...]]

${bold}DESCRIPTION${normal}

    A simple program that lets you associate directory paths with memorable names. 
    You can then use these names to quickly change directory. This program is most
    effective when combined with shell completion. 

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
        Display the generated functions for your shell profile. This will also produce
        suitable completion code.
    -p (--purge)
        Remove any alias for a path that is not a directory.
    -h (--help)
        Display this help message and exit.

${bold}EXAMPLES${normal}

    The following examples assume that the user has generated a function 'j'
    that invokes the jump program.

    Jump to the directory associated with ${underline}NAME${nounderline}:
    j ${underline}NAME${nounderline}

    List all stored aliases:
    j

    Create an alias for the current working directory using its basename:
    j -a

    Associate ${underline}NAME${nounderline} with the current working directory:
    j ${underline}NAME${nounderline} -a

    Delete a saved alias ${underline}NAME${nounderline}:
    j ${underline}NAME${nounderline} -d

    Rename a saved alias ${underline}NAME${nounderline} to ${underline}NEW_NAME${nounderline}:
    j ${underline}NAME${nounderline} -r ${underline}NEW_NAME${nounderline}
  \n
"

help_and_exit () {
  echo "$help_str"
  exit
}

jump_setup_code () {
  fname="j"
  echo "Two functions will be generated... one for invocation '${fname}', and one for completion '_${fname}'"
  echo "These will be printed to stdout and can be copy/pasted into your shell profile."
  echo "If you would like to use name other than '${fname}', please enter it below: "
  read -r fname
  if [ -z "${fname}" ]; then 
    fname="j"
  fi
  echo "##############################################"
  echo "### JUMP #####################################"
  echo "##############################################"
  printf "%s () {
  _jump_result=\"\$($_path_to_script \${@})\"
  if [ \${#} -eq 1 ]; then
    if case \${1} in -*) false;; *) true;; esac; then
      cd \"\$_jump_result\" && return
    fi
  fi
  echo \"\$_jump_result\"
}\n" "${fname}"
  echo "##############################################"
  echo "### JUMP COMPLETION (BASH) ###################"
  echo "##############################################"
  printf "_%s() {
  COMPREPLY=()
  local word=\"\${COMP_WORDS[COMP_CWORD]}\"
  if [ \"\$COMP_CWORD\" -eq 1 ]; then
    COMPREPLY=(\$(compgen -W \"\$($_path_to_script)\" -- \"\$word\"))
  fi
}
complete -F _%s %s\n" "${fname}" "${fname}" "${fname}"
  echo "##############################################"
  echo "### JUMP COMPLETION (ZSH) ####################"
  echo "##############################################"
  echo "autoload -U compinit; compinit"
  printf "_%s() {
  compadd \$($_path_to_script)
}
compdef _%s %s\n" "${fname}" "${fname}" "${fname}"
  echo "##############################################"
  exit
}

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
    jump_setup_code
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
    jump_setup_code
    ;;
  -h | --help)
    help_and_exit
    ;;
  *)
    help_and_exit
    ;;
esac

exit 
