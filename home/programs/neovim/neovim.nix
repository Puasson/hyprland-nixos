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
      timeoutlen = 300;
      clipboard = "unnamedplus";
      undofile = true;
      ignorecase = true;
      smartcase = true;
      splitbelow = true;
      splitright = true;
      wrap = false;
      swapfile = false;
    };

    globals.mapleader = " ";

    # Si nvim se abre con un directorio (nvim . / nvim ~/proyecto),
    # entrar en él, cerrar el buffer del directorio y mostrar Neo-tree
    # en su lugar. Sin args manda el dashboard de snacks; con un
    # fichero se abre el fichero con normalidad.
    autoCmd = [
      {
        event = [ "VimEnter" ];
        desc = "Open Neo-tree when nvim is called with a directory";
        callback.__raw = ''
          function()
            if vim.fn.argc() ~= 1 then
              return
            end
            local argv0 = vim.fn.argv(0)
            if argv0 == "" or vim.fn.isdirectory(argv0) ~= 1 then
              return
            end
            local dir = vim.fn.fnamemodify(argv0, ":p")
            vim.cmd("cd " .. vim.fn.fnameescape(dir))
            vim.cmd("bwipeout")
            vim.cmd("Neotree show dir=" .. vim.fn.fnameescape(dir))
          end
        '';
      }
    ];

    diagnostic.settings = {
      virtual_text = true;
      signs = true;
      underline = true;
      update_in_insert = false;
      severity_sort = true;
    };

    colorschemes.catppuccin = {
      enable = true;
      settings = {
        flavour = "mocha";
        transparent_background = true;
        float = {
          transparent = true;
          solid = false;
        };
        integrations = {
          cmp = true;
          gitsigns = true;
          treesitter = true;
          indent_blankline.enabled = true;
          native_lsp = {
            enabled = true;
            underlines = {
              errors = [ "undercurl" ];
              hints = [ "undercurl" ];
              warnings = [ "undercurl" ];
              information = [ "undercurl" ];
            };
          };
          neotree.enabled = true;
          which_key = true;
        };
      };
    };

    plugins = {
      web-devicons.enable = true;
      neo-tree.enable = true;
      treesitter = {
        enable = true;
        settings = {
          highlight.enable = true;
          indent.enable = true;
        };
      };
      lualine.enable = true;
      which-key.enable = true;
      bufferline.enable = true;
      gitsigns.enable = true;
      indent-blankline.enable = true;
      illuminate.enable = true;
      flash.enable = true;
      trouble.enable = true;
      lazygit.enable = true;

      snacks = {
        enable = true;
        settings = {
          bigfile.enabled = true;
          quickfile.enabled = true;
          image.enabled = true;
          picker.enabled = true;
        };
      };

      ccc = {
        enable = true;
        settings = {
          highlight_mode = "background";
          highlighter = {
            auto_enable = true;
            lsp = true;
          };
        };
      };

      lsp = {
        enable = true;
        inlayHints = true;
        servers = {
          nixd = {
            enable = true;
            settings.formatting.command = [ "nixfmt" ];
          };
          lua_ls.enable = true;
          ts_ls.enable = true;
          basedpyright = {
            enable = true;
            settings.basedpyright.analysis = {
              autoSearchPaths = true;
              diagnosticMode = "openFilesOnly";
              typeCheckingMode = "standard";
            };
          };
        };
      };

      conform-nvim = {
        enable = true;
        settings = {
          formatters_by_ft = {
            lua = [ "stylua" ];
            python = [
              "ruff_organize_imports"
              "ruff_format"
            ];
            javascript = {
              __unkeyed-1 = "prettierd";
              __unkeyed-2 = "prettier";
              stop_after_first = true;
            };
            typescript = {
              __unkeyed-1 = "prettierd";
              __unkeyed-2 = "prettier";
              stop_after_first = true;
            };
            javascriptreact = {
              __unkeyed-1 = "prettierd";
              __unkeyed-2 = "prettier";
              stop_after_first = true;
            };
            typescriptreact = {
              __unkeyed-1 = "prettierd";
              __unkeyed-2 = "prettier";
              stop_after_first = true;
            };
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
          python = [
            "ruff"
          ];
        };
        autoCmd = {
          event = [
            "BufEnter"
            "BufWritePost"
            "InsertLeave"
          ];
        };
      };

      cmp = {
        enable = true;
        autoEnableSources = true;
        settings = {
          snippet.expand.__raw = "function(args) require('luasnip').lsp_expand(args.body) end";
          sources = [
            { name = "nvim_lsp"; }
            { name = "luasnip"; }
            { name = "buffer"; }
            { name = "path"; }
          ];
          mapping = {
            "<CR>".__raw = "cmp.mapping.confirm({ select = true })";
            "<Tab>".__raw = ''
              cmp.mapping(function(fallback)
                if cmp.visible() then
                  cmp.select_next_item()
                elseif require('luasnip').expand_or_jumpable() then
                  require('luasnip').expand_or_jump()
                else
                  fallback()
                end
              end, { 'i', 's' })
            '';
            "<S-Tab>".__raw = ''
              cmp.mapping(function(fallback)
                if cmp.visible() then
                  cmp.select_prev_item()
                elseif require('luasnip').jumpable(-1) then
                  require('luasnip').jump(-1)
                else
                  fallback()
                end
              end, { 'i', 's' })
            '';
            "<C-Space>".__raw = "cmp.mapping.complete()";
            "<C-e>".__raw = "cmp.mapping.abort()";
          };
        };
      };

      luasnip.enable = true;
    };

    extraPackages = with pkgs; [
      ripgrep
      fd
      gcc
      stylua
      prettierd
      prettier
      nixfmt
      ruff
      imagemagick
    ];
  };
}
