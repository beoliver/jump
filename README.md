# jump

JUMP around your filesystem

`jump` lets you associate directory paths with names. You can then use these names to quickly change directory.

This is similar to adding aliases to you `.bash_profile`.

```sh
alias name="cd ${PATH_TO_DIR}"
```

However, unlike the use of `alias`, using `jump` you don't need to source you profile after adding an alias. It is also possible to use alias names that you otherwise conflict with existing applications.

```sh
jump [-h] [-a [PATH] | -s | -r NAME | -d] [ALIAS]
```

## Listing

When called with no arguments `jump` will list all alias names and their directories.

```sh
$ jump
```

## Adding

```sh
jump ALIAS -a PATH
```

### Example

```sh
[Users/you] $ jump pics -a ~/Pictures
[Users/you] $ jump docs -a ~/Documents
[Users/you] $ jump
docs    /Users/you/Documents
pics    /Users/you/Pictures
```

## Viewing an alias

```sh
jump ALIAS -s
```

### Example

```sh
[Users/you] $ jump pics -s
/Users/you/Pictures
[Users/you] $ cd $(jump pics -s)
[/Users/you/Pictures] $
```

## Teleporting

```sh
jump ALIAS
```

### Example

```sh
[Users/you] $ jump
docs    /Users/you/Documents
pics    /Users/you/Pictures
[Users/you] $ jump pics
[Users/you/Pictures] $
```

# Install

```sh
$ git clone git@github.com:beoliver/jump.git
$ cd jump
$ touch aliases.csv
```

Add the following to your `.bash_profile` or `.zshrc` file.

```sh
JUMP_DIR=~/Documents/projects/projects/jump

function j() {
    . "${JUMP_DIR}"/jump "${@}"
}

. ${JUMP_DIR}/completions.sh
```

```sh
$ source ~/.bash_profile # ~.zshrc
```

```sh
j
```