{ inputs, pkgs, ... }:

{
  imports = [
    inputs.nixvim.homeModules.nixvim
    ./dashboard.nix
    ./keymaps.nix
  ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    nixpkgs.source = inputs.nixpkgs;

    opts = {
      number = true;
      relativenumber = true;
      shiftwidth = 2;
      tabstop = 2;
      expandtab = true;
      termguicolors = true;
      signcolumn = "yes";
      cursorline = true;
      scrolloff = 8;
      updatetime = 250;
      clipboard = "unnamedplus";
    };

    globals.mapleader = " ";

    colorschemes.catppuccin = {
      enable = true;
      settings = {
        flavour = "mocha";
        integrations = {
          cmp = true;
          gitsigns = true;
          treesitter = true;
          telescope.enabled = true;
          indent_blankline.enabled = true;
          mini.enabled = true;
          native_lsp = {
            enabled = true;
            underlines = {
              errors = ["undercurl"];
              hints = ["undercurl"];
              warnings = ["undercurl"];
              information = ["undercurl"];
            };
          };
          navic.enabled = true;
          neotree.enabled = true;
          which_key = true;
        };
      };
    };

    plugins = {
      neo-tree.enable = true;
      telescope.enable = true;
      treesitter.enable = true;
      lualine.enable = true;
      which-key.enable = true;
      bufferline.enable = true;
      gitsigns.enable = true;
      indent-blankline.enable = true;
      illuminate.enable = true;
      flash.enable = true;
      trouble.enable = true;

      lsp = {
        enable = true;
        servers = {
          nil_ls.enable = true;
          lua_ls.enable = true;
          ts_ls.enable = true;
          pylsp = {
            enable = true;
            settings.plugins.ruff = {
              enabled = true;
              formatOnSave = true;
            };
          };
        };
      };

      conform-nvim = {
        enable = true;
        settings = {
          formatters_by_ft = {
            lua = [ "stylua" ];
            python = [ "ruff_organize_imports" "ruff_format" ];
            javascript = [ "prettierd" "prettier" ];
            typescript = [ "prettierd" "prettier" ];
            nix = [ "nixfmt" ];
            "_" = [ "trim_whitespace" ];
          };
          format_on_save = {
            lsp_format = "fallback";
            timeout_ms = 500;
          };
        };
      };

      lint = {
        enable = true;
        lintersByFt = {
          python = [ "ruff" "mypy" ];
        };
      };

      cmp = {
        enable = true;
        settings = {
          sources = [
            { name = "nvim_lsp"; }
            { name = "luasnip"; }
            { name = "buffer"; }
            { name = "path"; }
          ];
          mapping = {
            "<CR>" = "cmp.mapping.confirm({ select = true })";
            "<Tab>" = "cmp.mapping.select_next_item()";
            "<S-Tab>" = "cmp.mapping.select_prev_item()";
            "<C-Space>" = "cmp.mapping.complete()";
            "<C-e>" = "cmp.mapping.abort()";
          };
        };
      };

      luasnip.enable = true;
      cmp-nvim-lsp.enable = true;
      cmp-buffer.enable = true;
      cmp-path.enable = true;
    };

    extraPlugins = with pkgs.vimPlugins; [
      lazygit-nvim
    ];

    extraPackages = with pkgs; [
      ripgrep
      fd
      gcc
      stylua
      ruff
      mypy
      prettierd
      prettier
      nixfmt
      lazygit
    ];
  };
}
