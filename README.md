# hyprpunk-nix

NixOS configuration with modular tooling, Hyprland desktop, and dotfile management via GNU Stow.

Migrated from [hyprpunk](https://github.com/hinriksnaer/hyprpunk) (Fedpunk).

---

## Bootstrap

### 1. Install NixOS

Boot the NixOS installer, partition disks, then generate hardware config:

```bash
nixos-generate-config --show-hardware-config > /tmp/hardware-configuration.nix
```

Copy the output into `hosts/desktop/hardware-configuration.nix` in this repo.

### 2. Clone and build

```bash
git clone <this-repo> ~/hyprpunk-nix
sudo nixos-rebuild switch --flake ~/hyprpunk-nix#desktop
```

### 3. Deploy dotfiles

```bash
~/hyprpunk-nix/bootstrap.sh
```

This will:
- Stow all dotfile modules into `$HOME` (fish, neovim, tmux, btop, kitty, hyprland, waybar, etc.)
- Symlink themes to `~/.local/share/hyprpunk/themes/`
- Install Fisher (fish plugin manager)
- Install TPM (tmux plugin manager) and plugins
- Install yazi plugins
- Set the default theme (ayu-mirage)

### 4. Authenticate gcloud

```bash
gcloud auth login
gcloud auth application-default login
```

This sets up ADC for opencode's Vertex AI integration. Log out and back in for environment variables to take effect.

---

## Structure

```
.
├── flake.nix                     # Flake entry point (nixosModules + nixosConfigurations + containers)
├── hosts/
│   └── desktop/                  # Machine-specific config
│       ├── default.nix           # Imports base + desktop profile + hardware modules
│       └── hardware-configuration.nix
├── modules/                      # One NixOS module per tool (33 total)
│   ├── base.nix                  # Boot, locale, users, nix settings, stow
│   ├── opencode.nix              # opencode + google-cloud-sdk + Vertex env vars
│   ├── fish.nix                  # Fish shell + starship
│   ├── neovim.nix                # Neovim + tree-sitter
│   ├── tmux.nix                  # tmux
│   ├── hyprland.nix              # Hyprland + Wayland stack
│   ├── nvidia.nix                # NVIDIA proprietary drivers
│   └── ...                       # See modules/ for full list
├── profiles/                     # Composable presets
│   ├── tooling.nix               # All terminal/dev tools (container-safe)
│   ├── desktop.nix               # Tooling + GUI + opencode
│   └── container.nix             # Tooling + opencode (no GUI)
├── dotfiles/                     # Plain config files, deployed via stow (1:1 with modules)
│   ├── fish/.config/fish/        # Fish config, functions, plugins
│   ├── neovim/.config/nvim/      # Full neovim lua config
│   ├── tmux/.config/tmux/        # tmux.conf
│   ├── btop/.config/btop/        # btop config + themes
│   ├── kitty/.config/kitty/      # kitty.conf
│   ├── hyprland/.config/hypr/    # hyprland.conf + conf.d/ + scripts/
│   ├── hyprlock/.config/hypr/    # hyprlock.conf
│   ├── waybar/.config/waybar/    # config + style.css
│   ├── mako/.config/mako/        # notification config
│   ├── rofi/.config/rofi/        # config.rasi
│   ├── lazygit/.config/lazygit/  # lazygit config
│   ├── yazi/.config/yazi/        # yazi config + keymap
│   ├── rust/.cargo/              # cargo config (mold linker)
│   ├── scripts/.local/bin/       # Theme-manager + utility scripts
│   └── themes/                   # 12 themes (symlinked to ~/.local/share/hyprpunk/themes/)
├── containers/
│   └── default.nix               # OCI container image (dockerTools.buildLayeredImage)
└── bootstrap.sh                  # Stow dotfiles + install plugins
```

## Modules

Every module is independently importable via `nixosModules.<name>`:

```nix
# From another flake:
{
  inputs.hyprpunk.url = "github:you/hyprpunk-nix";
  # ...
  modules = [ inputs.hyprpunk.nixosModules.neovim ];
}
```

### Container-safe (terminal only)

`fish` `neovim` `tmux` `btop` `lazygit` `yazi` `gh` `cli-tools` `rust` `python` `nodejs` `golang` `dev-tools` `opencode`

### Desktop (GUI)

`hyprland` `kitty` `rofi` `hyprlock` `waybar` `mako` `thunar` `fonts` `audio` `multimedia` `flatpak` `zen-browser` `discord` `obsidian`

### Hardware (opt-in)

`nvidia` `bluetooth` `networking` `fancontrol`

## Profiles

| Profile | Includes | Use case |
|---|---|---|
| `tooling` | All container-safe modules | Dev containers, headless servers |
| `desktop` | Tooling + all GUI modules + opencode | Full workstation |
| `container` | Tooling + opencode | OCI dev container |

## Themes

12 themes with live-reload across hyprland, kitty, neovim, btop, waybar, mako, rofi, and hyprlock:

`aetheria` `ayu-mirage` `catppuccin` `catppuccin-latte` `matte-black` `nord` `osaka-jade` `ristretto` `rose-pine` `rose-pine-dark` `tokyo-night` `torrentz-hydra`

```bash
hyprpunk-theme-list              # List themes
hyprpunk-theme-set tokyo-night   # Switch theme
hyprpunk-theme-next              # Cycle forward
Super+T                          # Theme selector (rofi)
Super+Shift+T                    # Next theme
```

## Container Image

Build an OCI container with all tooling + opencode (no GUI):

```bash
nix build .#container
podman load < result
podman run -it hyprpunk-dev
```

## Adding a New Machine

1. Create `hosts/<hostname>/default.nix`
2. Import `../../modules/base.nix` + desired profile + hardware modules
3. Generate `hardware-configuration.nix` on the target
4. Add to `flake.nix` under `nixosConfigurations`
5. Build: `sudo nixos-rebuild switch --flake .#<hostname>`

## License

MIT
