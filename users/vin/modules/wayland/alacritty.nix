{ config, lib, pkgs, ... }:

{
  programs.alacritty = {
    enable = true;
    settings = {
      scrolling = {
        history = 100000;
        multiplier = 3;
      };

      font = {
        size = 11;

        normal = {
          family = "Iosevka Custom";
          style = "Book Extended";
        };
      };

      # Dracula
      colors = {
        primary = {
          background = "0x282A36";
          foreground = "0xF8F8F2";
        };

        cursor = {
          text = "0x44475A";
          cursor = "0xF8F8F2";
        };

        normal = {
          black = "0x282A36";
          red = "0xFF5555";
          green = "0x50FA7B";
          yellow = "0xF1FA8C";
          blue = "0xBD93F9";
          magenta = "0xFF79C6";
          cyan = "0x8BE9FD";
          white = "0xF8F8F2";
        };

        bright = {
          black = "0x4D4D4D";
          red = "0xFF6E67";
          green = "0x5AF78E";
          yellow = "0xF4F99D";
          blue = "0xCAA9FA";
          magenta = "0xFF92D0";
          cyan = "0x9AEDFE";
          white = "0xE6E6E6";
        };
      };

      mouse.url.modifiers = "Shift";

      selection.save_to_clipboard = true;

      cursor.vi_mode_style = "Beam";

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
      ];
    };
  };
}
