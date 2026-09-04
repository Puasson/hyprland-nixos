{ ... }:

{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings."*" = {
      HashKnownHosts = true;
      ForwardAgent = false;
      VerifyHostKeyDNS = true;
    };
    settings."github.com" = {
      HostName = "github.com";
      User = "git";
      IdentityFile = "~/.ssh/id_ed25519";
      ForwardAgent = false;
    };
  };
}
