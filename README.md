# jump

**jump** around your filesystem.

`jump` lets you associate directory paths with names. You can then use these names to quickly change directory.

This is similar to adding aliases to you `.bash_profile`.

```sh
alias name="cd ${PATH_TO_DIR}"
```

However, unlike the use of `alias`, using `jump` you don't need to source you profile after adding an alias. It is also possible to use alias names that you otherwise conflict with existing applications.

```bash
JUMP_DIR=~/dev/beoliver/jump
function j() {
    # we _source_ the script as it might perform a CD
    # the . is a "source" command
    . "${JUMP_DIR}"/jump "${@}"
}
. ${JUMP_DIR}/completions.sh
```