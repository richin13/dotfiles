# Dotfiles

> A collection of configuration files for the tools/programs I use in my day to day programming journey.

This dotfiles provide configurations for [Zsh](https://www.zsh.org/), [Neovim](https://github.com/neovim/neovim), [Tmux](https://github.com/tmux/tmux), [Alacritty](https://github.com/alacritty/alacritty) (and some more). This configurations are "optimized" for developing in Python and Typescript (mainly React).

The color scheme used everywhere is [Dracula](https://github.com/dracula/dracula-theme).

![Alacritty-ZSH-Tmux](./img/alacritty-zsh-tmux.png)

![Neovim-Treesitter-DraculaTheme](./img/nvim-treesitter-dracula.png)

## Pre-flight checks

Make sure to install:

- [asdf-vm](https://asdf-vm.com/#/core-manage-asdf?id=install)
- [vim-packager](https://github.com/kristijanhusak/vim-packager)
- [zplug](https://github.com/zplug/zplug#installation)
- [tpm](https://github.com/zplug/zplug#installation) (Optional, only if you plan to use Tmux [highly recommended])

And these `xstow xsel` using your package manager

## Installation

Just clone the repo and run Make

```
$ git clone git@github.com:richin13/dotfiles.git ~/dotfiles
$ cd ~/dotfiles
$ make dotfiles
```

## Troubleshoot

You might run into some issues when running `make dotfiles`. Under the hood, make will
execute `xstow` to create the symlinks to the dotfiles. First make sure you have
installed `xstow`

```
# When in LinuxMint (or any Debian based distro)
$ sudo apt install -y xstow
```

Another issue you might run into is `xstow` not being able to create the symlinks. This
happens when the files already exists in you home directory and are not symlinks.
Make sure to backup your existing dotfiles before proceeding.

## License

See `LICENSE`
