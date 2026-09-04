# ❄️ NixOS Hyprland Config

My personal NixOS setup: Hyprland + UWSM, Quickshell desktop shell,
Kitty + Catppuccin, Neovim (nixvim), SDDM Catppuccin, Tailscale,
AdGuard DNS with DoT/DNSSEC, Zen kernel.

## Screenshots

![Desktop](preview/preview.png)
![Desktop 2](preview/preview2.png)

## Features

- Hyprland (UWSM session) + Hyprlock/Hypridle
- Quickshell panels, launcher, power menu, notifications
- Kitty (Catppuccin) · Neovim via nixvim · Fastfetch
- SDDM Catppuccin-Mocha · GTK adw-gtk3-dark
- Tailscale · systemd-resolved (DNSSEC + DoT, AdGuard/Quad9)
- linux-zen · PipeWire · AppImage support

## Requirements

- NixOS x86_64, fresh install
- Git + a user with sudo

> ⚠️ Adapt paths to your user: this config hardcodes the username `edu`
> and the flake path `/home/edu/nixos#nixos` (Home Manager user in
> `flake.nix`, `system.autoUpgrade.flake`, rebuild aliases in
> `home/shell/bash.nix`). Replace them with your own username, home
> path, and `nixosConfigurations.<your-host>` attr.

## Install

```bash
# 1. Install NixOS (x86_64) and boot into it
# 2. Clone this repo
git clone https://github.com/Puasson/hyprland-nixos.git ~/nixos
cd ~/nixos
```

```bash
# 3. Adapt to your machine (REQUIRED — personal config)
# Regenerate hardware config:
sudo nixos-generate-config --show-hardware-config > hosts/nixos/hardware-configuration.nix
```

- In `flake.nix` / `hosts/nixos/configuration.nix` / `home/home.nix`:
  replace user `edu`, hostname `nixos`, flake path `/home/edu/nixos#nixos`
- In `hosts/nixos/configuration.nix`: review machine-specific values —
  `/mnt/Datos` mount (remove if you don't have that disk), timezone
  (`America/Lima`), locale (`es_PE.UTF-8`), console keymap (`la-latin1`),
  DNS nameservers, SDDM theme
- In `home/desktop/hyprland/configs/monitors.lua`: set your monitor/output

```bash
# 4. Validate, then apply
nix flake check
sudo nixos-rebuild test --flake .#nixos
sudo nixos-rebuild switch --flake .#nixos

# 5. Keep it updated
nix flake update && nix flake check
```

## Usage

- `nrt` = test · `nrs` = switch · `update` = `nix flake update`
  (aliases in `home/shell/bash.nix`).

## Notes

- `hosts/nixos/hardware-configuration.nix` is generated — regenerate, don't hand-edit.
- `system.stateVersion` / `home.stateVersion` are `26.05` — don't bump.
- `allowUnfree = true` required; Nix files use `nixfmt`.

## License

MIT © 2026 Puasson — see [LICENSE](LICENSE). Feel free to use and adapt.
