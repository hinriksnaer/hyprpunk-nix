# hawker

Chuck the system anywhere. NixOS desktop, dev containers, remote GPU clusters -- same config.

## Setup

```bash
git clone git@github.com:hinriksnaer/hawker.git ~/hawker
sudo nixos-rebuild switch --flake ~/hawker#desktop
./bootstrap.sh
```

## Structure

```
hosts/          Machines (hardware + components)
  desktop/        Hyprland desktop (NVIDIA, themes, apps)
  container/      Dev container (terminal tools only)
  helion/         GPU compiler dev (CUDA + PyTorch + terminal tools)
components/     Composable groups
  terminal.nix    fish, kitty, tmux, neovim, btop, lazygit, yazi, opencode, cli-tools, gh
  ui.nix          hyprland, sddm, waybar, rofi, mako, hyprlock, fonts, screenshot, cliphist
  apps.nix        firefox, thunar, steam, discord, obsidian, proton-pass, podman
  media.nix       pipewire audio
modules/        Individual NixOS modules
dotfiles/       Stow packages (each with optional modules.d/ and theme-hooks.d/)
containers/     OCI container images (built from host configs, no Dockerfile)
```

## Containers

Same flake, different targets:

```bash
hyprpunk-container build                        # dev container
hyprpunk-container --image helion build          # Helion GPU container
hyprpunk-container --image helion deploy ibm-kaiba  # build + push + enter
```

## Themes

12 themes across hyprland, kitty, neovim, btop, waybar, mako, rofi, hyprlock, opencode.

```
Super+T          Theme picker
Super+Shift+T    Next theme
Super+W          Wallpaper picker
Super+Shift+W    Next wallpaper
```

## Adding a Machine

1. Create `hosts/<name>/default.nix`, pick components
2. Generate `hardware-configuration.nix` on target
3. Add to `flake.nix` under `nixosConfigurations`
4. `sudo nixos-rebuild switch --flake .#<name>`
