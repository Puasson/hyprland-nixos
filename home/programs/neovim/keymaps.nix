{ ... }:

{
  programs.nixvim.keymaps = [
    {
      mode = [
        "n"
        "x"
      ];
      key = "j";
      action = "v:count == 0 ? 'gj' : 'j'";
      options = {
        expr = true;
        silent = true;
        desc = "Down";
      };
    }
    {
      mode = [
        "n"
        "x"
      ];
      key = "k";
      action = "v:count == 0 ? 'gk' : 'k'";
      options = {
        expr = true;
        silent = true;
        desc = "Up";
      };
    }
    {
      mode = [
        "n"
        "x"
      ];
      key = "<Down>";
      action = "v:count == 0 ? 'gj' : 'j'";
      options = {
        expr = true;
        silent = true;
        desc = "Down";
      };
    }
    {
      mode = [
        "n"
        "x"
      ];
      key = "<Up>";
      action = "v:count == 0 ? 'gk' : 'k'";
      options = {
        expr = true;
        silent = true;
        desc = "Up";
      };
    }

    {
      mode = "n";
      key = "<C-h>";
      action = "<C-w>h";
      options = {
        remap = true;
        desc = "Go to Left Window";
      };
    }
    {
      mode = "n";
      key = "<C-j>";
      action = "<C-w>j";
      options = {
        remap = true;
        desc = "Go to Lower Window";
      };
    }
    {
      mode = "n";
      key = "<C-k>";
      action = "<C-w>k";
      options = {
        remap = true;
        desc = "Go to Upper Window";
      };
    }
    {
      mode = "n";
      key = "<C-l>";
      action = "<C-w>l";
      options = {
        remap = true;
        desc = "Go to Right Window";
      };
    }

    {
      mode = "n";
      key = "<C-Up>";
      action = "<cmd>resize +2<cr>";
      options = {
        desc = "Increase Window Height";
      };
    }
    {
      mode = "n";
      key = "<C-Down>";
      action = "<cmd>resize -2<cr>";
      options = {
        desc = "Decrease Window Height";
      };
    }
    {
      mode = "n";
      key = "<C-Left>";
      action = "<cmd>vertical resize -2<cr>";
      options = {
        desc = "Decrease Window Width";
      };
    }
    {
      mode = "n";
      key = "<C-Right>";
      action = "<cmd>vertical resize +2<cr>";
      options = {
        desc = "Increase Window Width";
      };
    }

    {
      mode = "n";
      key = "<A-j>";
      action = "<cmd>execute 'move .+' . v:count1<cr>==";
      options = {
        desc = "Move Down";
      };
    }
    {
      mode = "n";
      key = "<A-k>";
      action = "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==";
      options = {
        desc = "Move Up";
      };
    }
    {
      mode = "i";
      key = "<A-j>";
      action = "<esc><cmd>m .+1<cr>==gi";
      options = {
        desc = "Move Down";
      };
    }
    {
      mode = "i";
      key = "<A-k>";
      action = "<esc><cmd>m .-2<cr>==gi";
      options = {
        desc = "Move Up";
      };
    }
    {
      mode = "v";
      key = "<A-j>";
      action = ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv";
      options = {
        desc = "Move Down";
      };
    }
    {
      mode = "v";
      key = "<A-k>";
      action = ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv";
      options = {
        desc = "Move Up";
      };
    }

    {
      mode = "n";
      key = "<S-h>";
      action = "<cmd>bprevious<cr>";
      options = {
        desc = "Prev Buffer";
      };
    }
    {
      mode = "n";
      key = "<S-l>";
      action = "<cmd>bnext<cr>";
      options = {
        desc = "Next Buffer";
      };
    }
    {
      mode = "n";
      key = "[b";
      action = "<cmd>bprevious<cr>";
      options = {
        desc = "Prev Buffer";
      };
    }
    {
      mode = "n";
      key = "]b";
      action = "<cmd>bnext<cr>";
      options = {
        desc = "Next Buffer";
      };
    }
    {
      mode = "n";
      key = "<leader>bb";
      action = "<cmd>e #<cr>";
      options = {
        desc = "Switch to Other Buffer";
      };
    }
    {
      mode = "n";
      key = "<leader>`";
      action = "<cmd>e #<cr>";
      options = {
        desc = "Switch to Other Buffer";
      };
    }
    {
      mode = "n";
      key = "<leader>bd";
      action = "<cmd>bdelete<cr>";
      options = {
        desc = "Delete Buffer";
      };
    }
    {
      mode = "n";
      key = "<leader>bD";
      action = "<cmd>bd<cr>";
      options = {
        desc = "Delete Buffer and Window";
      };
    }

    {
      mode = "n";
      key = "<esc>";
      action = "<cmd>noh<cr>";
      options = {
        desc = "Escape and Clear hlsearch";
      };
    }

    {
      mode = [
        "i"
        "n"
      ];
      key = "<C-s>";
      action = "<cmd>w<cr><esc>";
      options = {
        desc = "Save File";
      };
    }

    {
      mode = "v";
      key = "<";
      action = "<gv";
    }
    {
      mode = "v";
      key = ">";
      action = ">gv";
    }

    {
      mode = "n";
      key = "<leader>l";
      action = "<cmd>checkhealth<cr>";
      options = {
        desc = "CheckHealth";
      };
    }

    {
      mode = "n";
      key = "<leader>fn";
      action = "<cmd>enew<cr>";
      options = {
        desc = "New File";
      };
    }

    {
      mode = "n";
      key = "<leader>e";
      action = "<cmd>Neotree toggle dir=.<cr>";
      options = {
        desc = "Explorer NeoTree (cwd)";
      };
    }
    {
      mode = "n";
      key = "<leader>E";
      action = "<cmd>Neotree toggle<cr>";
      options = {
        desc = "Explorer NeoTree (Root Dir)";
      };
    }

    {
      mode = "n";
      key = "<leader><leader>";
      action = "<cmd>Telescope find_files<cr>";
      options = {
        desc = "Find Files";
      };
    }
    {
      mode = "n";
      key = "<leader>ff";
      action = "<cmd>Telescope find_files<cr>";
      options = {
        desc = "Find Files";
      };
    }
    {
      mode = "n";
      key = "<leader>fR";
      action = "<cmd>Telescope oldfiles<cr>";
      options = {
        desc = "Recent (cwd)";
      };
    }

    {
      mode = "n";
      key = "<leader>/";
      action = "<cmd>Telescope live_grep<cr>";
      options = {
        desc = "Grep (Root Dir)";
      };
    }
    {
      mode = "n";
      key = "<leader>sb";
      action = "<cmd>Telescope current_buffer_fuzzy_find<cr>";
      options = {
        desc = "Buffer Lines";
      };
    }
    {
      mode = "n";
      key = "<leader>sd";
      action = "<cmd>Telescope diagnostics<cr>";
      options = {
        desc = "Diagnostics";
      };
    }
    {
      mode = "n";
      key = "<leader>sh";
      action = "<cmd>Telescope help_tags<cr>";
      options = {
        desc = "Help Pages";
      };
    }
    {
      mode = "n";
      key = "<leader>sk";
      action = "<cmd>Telescope keymaps<cr>";
      options = {
        desc = "Key Maps";
      };
    }
    {
      mode = "n";
      key = "<leader>sm";
      action = "<cmd>Telescope marks<cr>";
      options = {
        desc = "Jump to Mark";
      };
    }
    {
      mode = "n";
      key = "<leader>so";
      action = "<cmd>Telescope vim_options<cr>";
      options = {
        desc = "Options";
      };
    }
    {
      mode = "n";
      key = "<leader>sR";
      action = "<cmd>Telescope resume<cr>";
      options = {
        desc = "Resume";
      };
    }
    {
      mode = "n";
      key = "<leader>sc";
      action = "<cmd>Telescope command_history<cr>";
      options = {
        desc = "Command History";
      };
    }
    {
      mode = "n";
      key = "<leader>sC";
      action = "<cmd>Telescope commands<cr>";
      options = {
        desc = "Commands";
      };
    }
    {
      mode = "n";
      key = "<leader>s\"";
      action = "<cmd>Telescope registers<cr>";
      options = {
        desc = "Registers";
      };
    }
    {
      mode = "n";
      key = "<leader>s/";
      action = "<cmd>Telescope search_history<cr>";
      options = {
        desc = "Search History";
      };
    }
    {
      mode = "n";
      key = "<leader>sa";
      action = "<cmd>Telescope autocommands<cr>";
      options = {
        desc = "Auto Commands";
      };
    }

    {
      mode = "n";
      key = "<leader>gc";
      action = "<cmd>Telescope git_commits<cr>";
      options = {
        desc = "Commits";
      };
    }
    {
      mode = "n";
      key = "<leader>gs";
      action = "<cmd>Telescope git_status<cr>";
      options = {
        desc = "Status";
      };
    }

    {
      mode = "n";
      key = "<leader>xx";
      action = "<cmd>Trouble diagnostics toggle<cr>";
      options = {
        desc = "Diagnostics (Trouble)";
      };
    }
    {
      mode = "n";
      key = "<leader>xd";
      action = "<cmd>Trouble diagnostics toggle filter.buf=0<cr>";
      options = {
        desc = "Buffer Diagnostics (Trouble)";
      };
    }
    {
      mode = "n";
      key = "<leader>xq";
      action = "<cmd>Trouble qflist toggle<cr>";
      options = {
        desc = "Quickfix List (Trouble)";
      };
    }
    {
      mode = "n";
      key = "<leader>xl";
      action = "<cmd>Trouble loclist toggle<cr>";
      options = {
        desc = "Location List (Trouble)";
      };
    }

    {
      mode = "n";
      key = "<leader>gg";
      action = "<cmd>LazyGit<cr>";
      options = {
        desc = "LazyGit";
      };
    }

    {
      mode = "n";
      key = "<leader>cf";
      action = "<cmd>lua require('conform').format({ async = true })<cr>";
      options = {
        desc = "Format Buffer";
      };
    }

    {
      mode = "n";
      key = "<leader>cp";
      action = "<cmd>CccPick<cr>";
      options = {
        desc = "Color Picker (ccc)";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader>cC";
      action = "<cmd>CccConvert<cr>";
      options = {
        desc = "Convert Color Format";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "gd";
      action = "<cmd>Telescope lsp_definitions<cr>";
      options = {
        desc = "Goto Definition";
      };
    }
    {
      mode = "n";
      key = "gr";
      action = "<cmd>Telescope lsp_references<cr>";
      options = {
        desc = "Goto References";
      };
    }
    {
      mode = "n";
      key = "gI";
      action = "<cmd>Telescope lsp_implementations<cr>";
      options = {
        desc = "Goto Implementation";
      };
    }
    {
      mode = "n";
      key = "gy";
      action = "<cmd>Telescope lsp_type_definitions<cr>";
      options = {
        desc = "Goto Type Definition";
      };
    }
    {
      mode = "n";
      key = "K";
      action = "<cmd>lua vim.lsp.buf.hover()<cr>";
      options = {
        desc = "Hover";
      };
    }
    {
      mode = "n";
      key = "<leader>ca";
      action = "<cmd>lua vim.lsp.buf.code_action()<cr>";
      options = {
        desc = "Code Action";
      };
    }
    {
      mode = "n";
      key = "<leader>cr";
      action = "<cmd>lua vim.lsp.buf.rename()<cr>";
      options = {
        desc = "Rename";
      };
    }
    {
      mode = "n";
      key = "<leader>cd";
      action = "<cmd>lua vim.diagnostic.open_float()<cr>";
      options = {
        desc = "Line Diagnostics";
      };
    }
    {
      mode = "n";
      key = "[d";
      action = "<cmd>lua vim.diagnostic.goto_prev()<cr>";
      options = {
        desc = "Prev Diagnostic";
      };
    }
    {
      mode = "n";
      key = "]d";
      action = "<cmd>lua vim.diagnostic.goto_next()<cr>";
      options = {
        desc = "Next Diagnostic";
      };
    }
  ];
}
