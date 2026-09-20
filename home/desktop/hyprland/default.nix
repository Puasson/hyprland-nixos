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
  home.file.".config/hypr/configs/autostart.lua".source = ./configs/autostart.lua;
  home.file.".config/hypr/configs/general.lua".source = ./configs/general.lua;
  home.file.".config/hypr/configs/decoration.lua".source = ./configs/decoration.lua;
  home.file.".config/hypr/configs/windowrules.lua".source = ./configs/windowrules.lua;
  home.file.".config/hypr/configs/keybindings.lua".source = ./configs/keybindings.lua;
  home.file.".config/hypr/configs/monitors.lua".text = ''
    hl.monitor({
    	output = "VGA-1",
    	mode = "1600x900@60",
    	position = "0x0",
    	scale = 1,
    })

    -- Fallback para cualquier otro monitor / si el principal no está presente
    hl.monitor({
    	output = "",
    	mode = "preferred",
    	position = "auto",
    	scale = "auto",
    })
  '';
}
