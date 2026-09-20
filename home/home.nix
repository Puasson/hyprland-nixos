{ pkgs, ... }:

{
  imports = [
    ./programs/kitty/kitty.nix
    ./programs/fastfetch/fastfetch.nix
    ./programs/neovim/neovim.nix
    ./programs/python/python.nix
    ./programs/mpv/mpv.nix
    ./programs/obs/obs.nix
    ./programs/ssh/ssh.nix
    ./desktop/hyprland/default.nix
    ./desktop/hyprland/hypridle.nix
    ./desktop/hyprland/hyprlock.nix
    ./desktop/quickshell/quickshell.nix
    ./shell/bash.nix
    ./theme/gtk.nix
  ];

  home = {
    username = "edu";
    homeDirectory = "/home/edu";
    stateVersion = "26.05";
  };

  services.ssh-agent.enable = true;
  xdg.userDirs.enable = true;

  home.packages = with pkgs; [
    brave-origin
    librewolf
    gimp
    audacity
    tauon
    cava
    onlyoffice-desktopeditors
    img2pdf
    obsidian
    gnome-text-editor
    opencode
    unzip
    zapzap
    bitwarden-desktop
    spotify
    mpvpaper
  ];
}
