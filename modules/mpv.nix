{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    youtube-dl
  ];

  programs.mpv = {
    enable = true;

    config = {
      alang = "jp,jpn,ja,Japanese,japanese,en,eng";
      audio-display = "no";
      cache-pause = "no";
      cache-secs = 600;
      cache = "yes";
      gpu-context = "wayland";
      mute = "no";
      osc = "yes";
      profile = "gpu-hq";
      screenshot-directory = "~/Pictures/mpv-screenshots/";
      screenshot-format = "png";
      slang = "en,eng";
      vo = "gpu";
      volume = 75;
      watch-later-directory = "${config.xdg.cacheHome}/mpv-watch-later/";
    };

    bindings = {
      # Basics
      SPACE = "cycle pause";
      "Alt+ENTER" = "cycle fullscreen";
      "Alt+x" = "quit-watch-later";
      "1" = "cycle border";
      "Ctrl+a" = "cycle ontop";
      n = "show-text \${file-name}";
      MBTN_LEFT = "cycle pause";
      MBTN_LEFT_DBL = "cycle fullscreen";
      MBTN_RIGHT = "ignore";
      z = "script-binding Blackbox";

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

      # Frame-step
      ">" = "frame-step";
      "<" = "frame-back-step";
    };
  };

  xdg.configFile = with pkgs; {
    "mpv/scripts" = {
      recursive = true;

      source = fetchFromGitHub {
        owner = "VideoPlayerCode";
        repo = "mpv-tools";
        rev = "39e49a4e17d522bb9f4b8e0f95b2c5ac5a1270c6";
        sha256 = "14pj50w8yznjp2ac77lb6sfvxw5rkx3vw2pz7w1avfj0xqyhyxax";
      } + "/scripts";
    };

    "mpv/scripts/navigator.lua".source = fetchFromGitHub {
      owner = "jonniek";
      repo = "mpv-filenavigator";
      rev = "a734966820e1b9e1b79de60c6f6f57d42f2231e1";
      sha256 = "0kvj36nwxz5izps0qm6qw6yrcd5fkkh1kb9zgb2z32hfbmvq22sy";
    } + "/navigator.lua";
  };
}
