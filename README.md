# tp

TelePort around your filesystem

# Example

```sh
$ tp --help
```

```sh
$ pwd
/Users/beoliver/Desktop
$ tp docs -a ~/Documents
$ tp docs
$ pwd
/Users/beoliver/Documents
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
