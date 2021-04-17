# tp

TelePort around your filesystem

# Example

```sh
$ tp docs -a ~/Documents
$ tp docs
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
