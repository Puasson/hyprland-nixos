{ ... }:

{
  programs.fastfetch = {
    enable = true;

    settings = {
      "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json";

      logo = {
        source = "NixOS2";
        type = "builtin";
        padding = {
          top = 1;
          left = 2;
        };
      };

      display = {
        separator = "  ";
      };

      modules = [
        {
          type = "custom";
          format = "{#90}  {#31}  {#32}  {#33}  {#34}  {#35}  {#36}  {#37}  {#38}  {#39} ";
        }

        "break"

        {
          type = "os";
          key = " ";
          keyColor = "yellow";
        }
        {
          type = "kernel";
          key = "";
          keyColor = "yellow";
        }
        {
          type = "packages";
          key = "󰏖";
          keyColor = "yellow";
        }
        {
          type = "shell";
          key = "";
          keyColor = "yellow";
        }

        "break"

        {
          type = "de";
          key = " ";
          keyColor = "blue";
        }
        {
          type = "wm";
          key = "";
          keyColor = "blue";
        }
        {
          type = "lm";
          key = "󰧨";
          keyColor = "blue";
        }
        {
          type = "wmtheme";
          key = "󰉼";
          keyColor = "blue";
        }
        {
          type = "icons";
          key = "󰀻";
          keyColor = "blue";
        }
        {
          type = "terminal";
          key = "";
          keyColor = "blue";
        }

        "break"

        {
          type = "host";
          key = " ";
          keyColor = "green";
        }
        {
          type = "cpu";
          key = "";
          keyColor = "green";
        }
        {
          type = "disk";
          key = "";
          keyColor = "green";
        }
        {
          type = "memory";
          key = "󰑭";
          keyColor = "green";
        }
        {
          type = "swap";
          key = "󰓡";
          keyColor = "green";
        }
        {
          type = "uptime";
          key = "󰅐";
          keyColor = "green";
        }

        "break"

        {
          type = "custom";
          format = "{#90}  {#31}  {#32}  {#33}  {#34}  {#35}  {#36}  {#37}  {#38}  {#39} ";
        }
      ];
    };
  };
}