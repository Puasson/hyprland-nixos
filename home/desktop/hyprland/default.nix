{ pkgs, ... }:

{
  home.packages = with pkgs; [
    libnotify
    pavucontrol
    playerctl
    grim
    networkmanagerapplet
    slurp
  ];

  home.file.".config/hypr/hyprland.lua".source = ./hyprland.lua;
  home.file.".config/hypr/configs".source = ./configs;
}
