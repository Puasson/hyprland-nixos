{ ... }:

{
  programs.nixvim.plugins.dashboard = {
    enable = true;
    settings = {
      theme = "hyper";
      config = {
        header = [
          ""
          "  ███████╗ ██████╗  █████╗ ██╗   ██╗████████╗ ██████╗ "
          "  ██╔════╝██╔═══██╗██╔══██╗██║   ██║╚══██╔══╝██╔═══██╗"
          "  ███████╗██║   ██║███████║██║   ██║   ██║   ██║   ██║"
          "  ╚════██║██║   ██║██╔══██║██║   ██║   ██║   ██║   ██║"
          "  ███████║╚██████╔╝██║  ██║╚██████╔╝   ██║   ╚██████╔╝"
          "  ╚══════╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝    ╚═╝    ╚═════╝"
          ""
        ];
        week_header.enable = true;
        shortcut = [
          {
            icon = " ";
            icon_hl = "@variable";
            desc = "Files";
            group = "Label";
            action = "Telescope find_files";
            key = "f";
          }
          {
            icon = " ";
            desc = "Recent Files";
            group = "Number";
            action = "Telescope oldfiles";
            key = "r";
          }
          {
            icon = " ";
            desc = "Grep";
            group = "DiagnosticHint";
            action = "Telescope live_grep";
            key = "g";
          }
          {
            icon = " ";
            desc = "Config";
            group = "Statement";
            action = "edit ~/nixos/home/programs/neovim/neovim.nix";
            key = "c";
          }
          {
            icon = "󰒲 ";
            desc = "Lazy";
            group = "Identifier";
            action = "Lazy";
            key = "l";
          }
        ];
        footer.__raw = "{ '', '  Neovim v' .. tostring(vim.version()) .. ' ', }";
        mru.limit = 10;
        project.enable = false;
      };
    };
  };
}
