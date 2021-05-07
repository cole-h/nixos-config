{ config, lib, pkgs, ... }:

{
  # set up proper emoji fallback, but just for Alacritty
  xdg.configFile."fontconfig/fonts.conf".text = ''
    <?xml version="1.0"?>
    <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
    <fontconfig>
      <alias>
        <family>term</family>
        <prefer>
          <family>Iosevka Custom</family>
          <family>Noto Color Emoji</family>
         </prefer>
      </alias>

      <selectfont>
        <rejectfont>
          <pattern>
            <patelt name="family">
              <string>Bitstream Vera Sans</string>
            </patelt>
          </pattern>
        </rejectfont>
      </selectfont>
    </fontconfig>
  '';

  home.packages = [
    pkgs.foot
  ];

  programs.alacritty = {
    enable = false;
    settings = {
      scrolling = {
        history = 100000;
        multiplier = 3;
      };

      font = {
        size = 11;

        normal = {
          family = "term";
          style = "Book Extended";
        };
      };

      mouse.url.modifiers = "Shift";

      selection.save_to_clipboard = true;

      cursor = {
        style.blinking = "On";
        vi_mode_style = "Beam";
      };

      key_bindings = [
        {
          key = "Escape";
          mods = "Control";
          mode = "Vi";
          action = "ScrollToBottom";
        }
        {
          key = "Escape";
          mods = "Control";
          action = "ToggleViMode";
        }
        {
          key = "NumpadEnter";
          chars = "\\x0d";
        }
      ];
    };
  };
}
