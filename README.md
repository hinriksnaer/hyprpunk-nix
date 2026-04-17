# hyprpunk-nix

NixOS configuration for Hyprland desktop with NVIDIA, dotfiles via GNU Stow, and Proton Pass SSH agent.

Migrated from [hyprpunk](https://github.com/hinriksnaer/hyprpunk) (Fedora).

## Quick Start

```bash
git clone git@github.com:hinriksnaer/hyprpunk-nix.git ~/hyprpunk-nix
sudo nixos-rebuild switch --flake ~/hyprpunk-nix#desktop
./bootstrap.sh
```

## Structure

```
hosts/          Machine configs (hardware + components)
components/     Composable collections of modules
  terminal.nix  fish, kitty, tmux, btop, lazygit, yazi, neovim, cli-tools, gh
  ui.nix        hyprland, waybar, rofi, hyprlock, mako, fonts, proton-pass
  apps.nix      thunar, steam
  dev.nix       dev-tools
  media.nix     audio, multimedia
modules/        Individual NixOS modules
dotfiles/       Plain config files deployed via stow
```

## Themes

12 themes with live-reload across hyprland, kitty, neovim, btop, waybar, mako, rofi:

```bash
hyprpunk-theme-set torrentz-hydra
hyprpunk-theme-next
hyprpunk-theme-list
```

## Adding a Machine

1. Create `hosts/<name>/default.nix`, import base + components
2. Generate `hardware-configuration.nix` on target
3. Add to `flake.nix` under `nixosConfigurations`
4. `sudo nixos-rebuild switch --flake .#<name>`
