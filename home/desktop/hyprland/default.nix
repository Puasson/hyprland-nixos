{ pkgs, ... }:

{
  home.packages = with pkgs; [
    libnotify
    ffmpegthumbnailer
    pavucontrol
    playerctl
    grim
    networkmanagerapplet
    hypridle
    slurp
    btop
  ];

  home.file.".config/hypr/hyprland.lua".source = ./hyprland.lua;
  home.file.".config/hypr/configs".source = ./configs;
}
