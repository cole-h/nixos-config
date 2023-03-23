{ config, pkgs, my, ... }:

{
  home.packages = with pkgs; [
    yt-dlp
    streamlink
    # jellyfin-mpv-shim
  ];

  xdg.configFile = with pkgs; {
    "mpv/scripts/navigator.lua".source = fetchFromGitHub
      {
        owner = "jonniek";
        repo = "mpv-filenavigator";
        rev = "a67c8280a7711cfaa5871f55d53ddb017f6d7b4c";
        sha256 = "0kvj36nwxz5izps0qm6qw6yrcd5fkkh1kb9zgb2z32hfbmvq22sy";
      } + "/navigator.lua";
  };

  programs.mpv = {
    enable = true;

    config = {
      alang = "jp,jpn,ja,Japanese,japanese,en,eng";
      audio-display = "no";
      cache-pause = "no";
      cache = "yes";
      gpu-context = "wayland";
      mute = "no";
      osc = "yes";
      profile = "gpu-hq";
      screenshot-directory = "~/Pictures/mpv-screenshots/";
      screenshot-format = "png";
      slang = "en,eng";
      vo = "gpu";
      # volume = 75;
      watch-later-directory = "${config.xdg.cacheHome}/mpv-watch-later/";
      ytdl-format = "bestvideo[height<=?1080][vcodec!=?vp9]+bestaudio/best";
      save-position-on-quit = true;
      osd-font = "Bitstream Vera Sans";
    };

    bindings = {
      # Basics
      SPACE = "cycle pause";
      "Alt+ENTER" = "cycle fullscreen";
      "Alt+x" = "quit-watch-later";
      "1" = "cycle border";
      "Ctrl+a" = "cycle ontop";
      n = ''show-text ''${media-title}'';
      MBTN_LEFT = "cycle pause";
      MBTN_LEFT_DBL = "cycle fullscreen";
      MBTN_RIGHT = "ignore";

      # Video
      v = "cycle sub-visibility";
      "Ctrl+LEFT" = "sub-seek -1";
      "Ctrl+RIGHT" = "sub-seek 1";
      PGUP = "playlist-next; write-watch-later-config";
      PGDWN = "playlist-prev; write-watch-later-config";
      "Alt+1" = "set window-scale 0.5";
      "Alt+2" = "set window-scale 1.0";
      "Alt+3" = "set window-scale 2.0";
      "Alt+i" = "screenshot";
      s = "ignore";

      # Audio
      UP = "add volume +5";
      DOWN = "add volume -5";
      WHEEL_UP = "add volume +5";
      WHEEL_DOWN = "add volume -5";
      "+" = "add audio-delay 0.100";
      "-" = "add audio-delay -0.100";
      a = "cycle audio";
      "Shift+a" = "cycle audio down";
      "Ctrl+M" = "cycle mute";
      "=" = ''af toggle "lavfi=[pan=1c|c0=0.5*c0+0.5*c1]" ; show-text "Audio mix set to Mono"'';

      # Frame-step
      ">" = "frame-step";
      "<" = "frame-back-step";

      # Seek to timestamp
      "ctrl+t" = ''script-message-to console type "set time-pos "'';
    };
  };
}
