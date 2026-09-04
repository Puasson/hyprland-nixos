{ pkgs, ... }:

{
  home.packages = with pkgs; [
    (wrapOBS {
      plugins = with pkgs.obs-studio-plugins; [
        obs-vkcapture
        obs-pipewire-audio-capture
        obs-vaapi
      ];
    })
  ];
}
