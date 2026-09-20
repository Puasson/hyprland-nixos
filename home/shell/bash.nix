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
      "img" = "kitten icat";
      ".." = "cd ..";
      nrs = "sudo nixos-rebuild switch --flake $HOME/nixos#nixos";
      nrt = "sudo nixos-rebuild test --flake $HOME/nixos#nixos";
      delete = "sudo nix-collect-garbage -d";
      update = "nix flake update";
      "datos" = "cd /mnt/Datos";
      "work" = "cd /mnt/Datos/Workstation";
    };
  };
}
