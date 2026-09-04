{ ... }:

{
  programs.quickshell = {
    enable = true;
    systemd.enable = true;

    configs = {
      default = ./quickshell;
    };

    activeConfig = "default";
  };
}
