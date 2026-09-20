{ pkgs, ... }:

{
  home.packages = with pkgs; [
    python3
    uv
    ruff
  ];

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };

  home.sessionVariables = {
    UV_PYTHON_PREFERENCE = "only-system";
    UV_PYTHON = "${pkgs.python3}/bin/python3";
    PIP_DISABLE_PIP_VERSION_CHECK = "1";
    PYTHONDONTWRITEBYTECODE = "1";
  };
}
