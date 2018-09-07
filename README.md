# DOTFILES

These are mainly based on [Sam Roeca's dotfiles](https://github.com/pappasam/dotfiles) with
a few modifications to adapt them to my current workflow.

This a work in progress :wink:

## Installation

Just clone the repo and run Make

```
$ git clone git@github.com:richin13/dotfiles.git ~/dotfiles
$ cd ~/dotfiles
$ make dotfiles
```

## Troubleshoot

You might run into some issues when running `make dotfiles`. Under the hood, make will
execute `stow` to create the symlinks to the dotfiles. First make sure you have
installed `stow`

```
# When in ArchLinux
$ sudo pacman -S --noconfirm stow

# When in LinuxMint (or any Debian based distro)
$ sudo apt install -y stow
```

Another issue you might run into is `stow` not being able to create the symlinks. This
happens when the files already exists and are not symlinks. Make sure to backup
your existing dotfiles before proceeding.

## License

See `LICENSE`
