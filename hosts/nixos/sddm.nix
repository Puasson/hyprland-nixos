{ pkgs, ... }:
let
  sddm-astronaut-custom =
    (pkgs.sddm-astronaut.override {
      embeddedTheme = "japanese_aesthetic";
      themeConfig = {
        Background = "Backgrounds/Iuno.jpg";
      };
    }).overrideAttrs
      (oldAttrs: {
        installPhase = oldAttrs.installPhase + ''
          chmod u+w $out/share/sddm/themes/sddm-astronaut-theme/Backgrounds/
          cp ${../assets/Iuno.jpg} $out/share/sddm/themes/sddm-astronaut-theme/Backgrounds/Iuno.jpg
        '';
      });
in

{
  environment.systemPackages = [ sddm-astronaut-custom ];

  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true;
      theme = "sddm-astronaut-theme";
      extraPackages = with pkgs; [
        sddm-astronaut-custom
        qt6.qtmultimedia
        qt6.qtsvg
        qt6.qtvirtualkeyboard
      ];
    };
    defaultSession = "hyprland-uwsm";
    autoLogin.enable = false;
  };
}
