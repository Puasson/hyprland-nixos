{ ... }:

{
  programs.mpv = {
    enable = true;
    config = {
      loop-file = "inf";
      loop-playlist = "inf";
    };
  };
}
