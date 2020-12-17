{ config, lib, pkgs, ... }:
let
  inherit (pkgs)
    stdenv
    fetchFromGitHub
    ;

  kak-smarttab = stdenv.mkDerivation {
    pname = "smarttab.kak";
    version = "unstable-2020-09-14";

    src = fetchFromGitHub {
      repo = "smarttab.kak";
      owner = "andreyorst";
      rev = "e7fe8efd0b91ab8dc1c99c131f138de9b38fd965";
      sha256 = "sha256-88V6EywZPqMnFriKmrTWiOq9SicPNux13yfitHutI3U=";
    };

    installPhase = ''
      mkdir -p $out/share/kak/autoload/plugins
      cp rc/* $out/share/kak/autoload/plugins
    '';
  };

  kak-connect = stdenv.mkDerivation {
    pname = "connect.kak";
    version = "unstable-2020-11-25";

    src = fetchFromGitHub {
      repo = "connect.kak";
      owner = "alexherbo2";
      rev = "56fc2476e8cf126fb16654f4a08582f4f76b0d3d";
      sha256 = "sha256-2+wKjkS5DRZN8W2xJ09pe8jH8mGV5sP4WQB0z1sG6+M=";
    };

    dontBuild = true;

    installPhase = ''
      mkdir -p $out/bin $out/share/kak/autoload/plugins
      cp bin/* $out/bin
      cp -r rc/* $out/share/kak/autoload/plugins
    '';
  };

  kak-prelude = stdenv.mkDerivation {
    pname = "prelude.kak";
    version = "unstable-2020-09-06";

    src = fetchFromGitHub {
      repo = "prelude.kak";
      owner = "alexherbo2";
      rev = "f1e0f4d5cb62a36924e3f8ba6824d6aed8c19d23";
      sha256 = "sha256-DNHORL++3Pw+Qt+jqTZDjbqkw0WGwb99+oJu/BXKzN4=";
    };

    installPhase = ''
      mkdir -p $out/share/kak/autoload/plugins
      cp rc/* $out/share/kak/autoload/plugins
    '';
  };

in
{
  home.packages = [ kak-connect ];

  programs.kakoune = {
    enable = true;

    config = {
      numberLines = {
        enable = true;
        relative = true;
        highlightCursor = true;
        separator = ''" "'';
      };

      hooks = [
        # {
        #   name = "RegisterModified";
        #   option = ''"'';
        #   commands = ''
        #     nop %sh{
        #       printf %s "$kak_main_reg_dquote" | wl-copy >/dev/null 2>&1 &
        #     }
        #   '';
        # }
        {
          name = "ModuleLoaded";
          option = "smarttab";
          commands = ''
            set-option global softabstop 4
          '';
        }
        {
          name = "WinSetOption";
          option = "filetype=(rust|nix)";
          commands = "expandtab";
        }
        # {
        #   name = "ModuleLoaded";
        #   option = "tmux";
        #   commands = "alias global popup tmux-terminal-window";
        # }
      ];

      keyMappings = [
        {
          mode = "user";
          docstring = "Paste before";
          key = "P";
          effect = "!wl-paste -n<ret>";
        }
        {
          mode = "user";
          docstring = "Paste after";
          key = "p";
          effect = "<a-!>wl-paste -n<ret>";
        }
      ];
    };

    plugins = with pkgs.kakounePlugins; [
      kak-powerline
      kak-auto-pairs
      kak-vertical-selection
      kak-buffers
    ] ++ [
      kak-prelude
      kak-smarttab
      kak-connect
    ];

    extraConfig = ''
      set-option global startup_info_version 20200901

      hook global RegisterModified '"' %{ nop %sh{
        printf %s "$kak_main_reg_dquote" | wl-copy > /dev/null 2>&1 &
      }}

      require-module connect
      require-module connect-fzf

      hook global ModuleLoaded tmux %{
        alias global terminal tmux-terminal-window
      }
   '';
  };
}
