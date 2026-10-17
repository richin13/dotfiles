# My dotfiles

Public repo -- keep confidential stuff out of here.

## Layout

- ./dotfiles: symlinked into `~` with `xstow -t ~ -R dotfiles/` (`make dotfiles`)
- ./skills: shared agent skills, symlinked into `./dotfiles/.agents/skills` and `./dotfiles/.claude/skills`; `make skill` bootstraps a new one via `./scripts/bootstrap-skill`
- ./scripts: utility scripts

## Tools

- Neovim: ./dotfiles/.config/nvim
- Zsh: common settings in ./dotfiles/.bashrc, zsh-specific in ./dotfiles/.zshrc
- Mise: ./dotfiles/.config/mise
- Tmux: ./dotfiles/.config/tmux/
- Codex: ./dotfiles/.agents
- Claude Code: ./dotfiles/.claude
- Pi: ./dotfiles/.pi

Others are usually configured under ./dotfiles/.config. Agent config dirs are public: commit only what's safe to share.

## Environment

- Personal: Arch Linux, Zsh (mostly codex)
- Work: Ubuntu (PopOS), Zsh (mostly claude code)
- Raspberry Pi: Raspbian, Bash

Consider all three distros when editing .zshrc or .bashrc.
