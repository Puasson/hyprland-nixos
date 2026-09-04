{ ... }:

{
  programs.kitty = {
    enable = true;
    themeFile = "Catppuccin-Frappe";
    shellIntegration.enableBashIntegration = true;

    font = {
      name = "Iosevka Nerd Font";
      size = 11.5;
    };

    settings = {
      cursor_beam_thickness = "1";
      cursor_shape = "underline";
      url_color = "#fa89c1";
      url_style = "curly";
      detect_urls = true;
      open_url_with = "default";
      background_opacity = "0.75";
      window_padding_width = 8;
      hide_window_decorations = true;
      disable_ligatures = "never";
      tab_bar_style = "powerline";
      tab_bar_min_tabs = 2;
      tab_switch_strategy = "previous";
      active_border_color = "#a6b7b7";
      inactive_border_color = "#000000";
      enable_audio_bell = false;
      confirm_os_window_close = 0;
      scrollback_lines = 50000;
      scrollback_pager = "nvim -R -c 'set nowrap nonumber nolist showtabline=0' +G -";
      scrollback_fill_enlarged_window = true;
      wheel_scroll_multiplier = "3.0";
      touch_scroll_multiplier = "3.0";
      copy_on_select = "clipboard";
      strip_trailing_spaces = "smart";
      clipboard_control = "write-clipboard write-primary";
      shell_integration = "enabled";
      update_check_interval = 0;
      enabled_layouts = "splits,stack,tall,grid";
      remember_window_size = true;
      mouse_hide_wait = "1.0";
      repaint_delay = 10;
      input_delay = 3;
      sync_to_monitor = true;
    };

    keybindings = {
      "ctrl+left" = "neighboring_window left";
      "ctrl+right" = "neighboring_window right";
      "ctrl+up" = "neighboring_window up";
      "ctrl+down" = "neighboring_window down";
      "ctrl+shift+h" = "neighboring_window left";
      "ctrl+shift+j" = "neighboring_window down";
      "ctrl+shift+k" = "neighboring_window up";
      "ctrl+shift+l" = "neighboring_window right";
      "ctrl+shift+r" = "start_resizing_window";
      "ctrl+shift+u" = "next_layout";
      "ctrl+shift+9" = "last_used_layout";
      "ctrl+shift+w" = "close_window";
      "ctrl+shift+d" = "detach_window";

      "ctrl+shift+t" = "new_tab_with_cwd";
      "ctrl+shift+q" = "close_tab";
      "alt+left" = "previous_tab";
      "alt+right" = "next_tab";
      "ctrl+shift+1" = "goto_tab 1";
      "ctrl+shift+2" = "goto_tab 2";
      "ctrl+shift+3" = "goto_tab 3";
      "ctrl+shift+4" = "goto_tab 4";
      "ctrl+shift+5" = "goto_tab 5";
      "ctrl+shift+6" = "goto_tab 6";
      "ctrl+shift+7" = "goto_tab 7";
      "ctrl+shift+8" = "goto_tab 8";
      "ctrl+shift+enter" = "new_window_with_cwd";

      "ctrl+shift+z" = "jump_to_previous_prompt";
      "ctrl+shift+x" = "jump_to_next_prompt";

      "ctrl+shift+s" = "show_scrollback";
      "ctrl+shift+g" = "show_last_command_output";

      "ctrl+shift+e" = "open_url_with_hints";
      "ctrl+shift+o" = "kitten hints --type linenum --linenum-action=tab nvim +{line} {path}";
      "ctrl+shift+y" = "kitten hints --type path --program -";

      "ctrl+shift+c" = "copy_to_clipboard";
      "ctrl+shift+v" = "paste_from_clipboard";
      "f1" = "copy_to_buffer a";
      "f2" = "paste_from_buffer a";
      "f3" = "copy_to_buffer b";
      "f4" = "paste_from_buffer b";
    };
  };
}
