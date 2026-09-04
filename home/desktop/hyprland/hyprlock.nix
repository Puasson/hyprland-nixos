{ ... }:

{
  programs.hyprlock = {
    enable = true;

    settings = {
      general = {
        disable_loading_bar = false;
        hide_cursor = true;
        no_fade_in = false;
        no_fade_out = false;
      };

      background = [
        {
          monitor = "";
          path = "screenshot";
          blur_passes = 3;
          blur_size = 8;
          noise = 0.0117;
          contrast = 0.8916;
          brightness = 0.8172;
          vibrancy = 0.1696;
          vibrancy_darkness = 0.0;
        }
      ];

      input-field = [
        {
          monitor = "";
          size = "200, 50";
          outline_thickness = 3;
          dots_size = 0.33;
          dots_spacing = 0.15;
          dots_center = true;
          outer_color = "rgb(4CC27E)";
          inner_color = "rgb(1E1E2E)";
          font_color = "rgb(CDD6F4)";
          fade_on_empty = true;
          placeholder_text = ''<i>Contraseña...</i>'';
          hide_input = false;
        }
      ];

      label = [
        {
          monitor = "";
          text = ''$TIME'';
          font_size = 64;
          font_family = "Inter";
          color = "rgb(CDD6F4)";
          position = "0, 80";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };
}
