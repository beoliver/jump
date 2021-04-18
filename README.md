# tp

TelePort around your filesystem

`tp` lets you associate directory paths with names. You can then use these names to quickly change directory.

This is similar to adding aliases to you `.bash_profile`.

```sh
alias name="cd ${PATH_TO_DIR}"
```

However, unlike the use of `alias`, using `tp` you don't need to source you profile after adding an alias. It is also possible to use alias names that you otherwise conflict with existing applications.

## Listing

When called with no arguments `tp` will list all alias names and their directories.

```sh
$ tp
```

## Adding

```sh
tp <alias> -a <path>
```

### Example

```sh
[Users/you] $ tp pics -a ~/Pictures
[Users/you] $ tp docs -a ~/Documents
[Users/you] $ tp
docs    /Users/you/Documents
pics    /Users/you/Pictures
```

## Viewing an alias

```sh
tp <alias> -s
```

### Example

```sh
[Users/you] $ tp pics -s
/Users/you/Pictures
[Users/you] $ cd $(tp pics -s)
[/Users/you/Pictures] $
```

## Teleporting

```sh
tp <alias>
```

### Example

```sh
[Users/you] $ tp
docs    /Users/you/Documents
pics    /Users/you/Pictures
[Users/you] $ tp pics
[Users/you/Pictures] $
```

# Install

```sh
$ git clone git@github.com:beoliver/tp.git
$ cd tp
$ touch aliases.csv
```

Add the following to your `.bash_profile` or `.zshrc` file.

```sh
function tp() {
    local DIR=<path-to-cloned-repo>
    . "${DIR}"/tp "${@}"
}
```

```sh
$ source ~/.bash_profile # ~.zshrc
```

# TODO

Completion when searching typing a tag
