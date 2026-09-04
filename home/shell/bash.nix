{ ... }:

{
  programs.oh-my-posh = {
    enable = true;
    enableBashIntegration = true;
    useTheme = "spaceship";
  };

  programs.bash = {
    enable = true;
    shellAliases = {
      "station" = "cd /mnt/Datos/Workstation";
      "img" = "kitten icat";
      "diff" = "kitty +kitten diff";
      "kssh" = "kitty +kitten ssh";
      ".." = "cd ..";
      datos = "cd /mnt/Datos";
      nrs = "sudo nixos-rebuild switch --flake $HOME/nixos#nixos";
      nrt = "sudo nixos-rebuild test --flake $HOME/nixos#nixos";
      delete = "sudo nix-collect-garbage -d";
      update = "nix flake update";
    };
  };
}
