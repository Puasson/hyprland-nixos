{ ... }:

{
  programs.nixvim.plugins.snacks.settings.dashboard = {
    enabled = true;
    width = 60;
    pane_gap = 4;
    preset = {
      header = ''
        ███████╗██████╗ ██╗   ██╗
        ██╔════╝██╔══██╗██║   ██║
        █████╗  ██║  ██║██║   ██║
        ██╔══╝  ██║  ██║██║   ██║
        ███████╗██████╔╝╚██████╔╝
        ╚══════╝╚═════╝  ╚═════╝
             ニックス • ᴇᴅᴜ • えどぅ
              ( ˶˃ ᵕ ˂˶ ) ♡ﾟ'';
      keys = [
        {
          icon = " ";
          key = "f";
          desc = "Find File";
          action = ":lua Snacks.picker.files()<CR>";
        }
        {
          icon = " ";
          key = "n";
          desc = "New File";
          action = ":ene | startinsert<CR>";
        }
        {
          icon = " ";
          key = "r";
          desc = "Recent Files";
          action = ":lua Snacks.picker.recent()<CR>";
        }
        {
          icon = " ";
          key = "g";
          desc = "Find Text";
          action = ":lua Snacks.picker.grep()<CR>";
        }
        {
          icon = " ";
          key = "c";
          desc = "NixOS Config";
          action = ":lua Snacks.picker.files({ cwd = \"/home/edu/nixos\" })<CR>";
        }
        {
          icon = " ";
          key = "G";
          desc = "LazyGit";
          action = ":LazyGit<CR>";
        }
        {
          icon = " ";
          key = "q";
          desc = "Quit";
          action = ":qa<CR>";
        }
      ];
    };
    sections = [
      { section = "header"; }
      {
        section = "keys";
        gap = 1;
        padding = 1;
      }
      {
        icon = " ";
        title = "Recent Files";
        section = "recent_files";
        indent = 2;
        padding = 1;
      }
      {
        icon = " ";
        title = "Projects";
        section = "projects";
        indent = 2;
        padding = 1;
      }
      { section = "startup"; }
    ];
  };
}
