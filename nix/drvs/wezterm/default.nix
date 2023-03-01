{ lib
, ncurses
, pkg-config
, fontconfig
, installShellFiles
, openssl
, libGL
, libX11
, libxkbcommon
, xcbutil
, xcbutilimage
, wayland
, nixosTests
, runCommand
, wezterm-flake
, naersk
}:

let
  date = lib.substring 0 8 wezterm-flake.lastModifiedDate; # YYYYMMDD
  time = lib.substring 8 14 wezterm-flake.lastModifiedDate; # HHMMSS
  rev = lib.substring 0 8 wezterm-flake.rev;
in
naersk.buildPackage rec {
  name = "wezterm";
  # git -c core.abbrev=8 show -s --format=%cd-%h --date=format:%Y%m%d-%H%M%S | wl-copy -n
  version = "${date}-${time}-${rev}";

  src = wezterm-flake;
  gitSubmodules = true;

  nativeBuildInputs = [
    installShellFiles
    pkg-config
  ];

  buildInputs = [
    fontconfig
    libX11
    libxkbcommon
    openssl
    wayland
    xcbutil
    xcbutilimage
  ];

  cargoBuildOptions = x: x ++ [ "--features distro-defaults" ];

  overrideMain = { ... }: {
    postPatch = ''
      echo ${version} > .tag

      # tests are failing with: Unable to exchange encryption keys
      rm -r wezterm-ssh/tests
    '';

    postInstall = ''
      mkdir -p $out/nix-support
      echo "${passthru.terminfo}" >> $out/nix-support/propagated-user-env-packages

      install -Dm644 assets/icon/terminal.png $out/share/icons/hicolor/128x128/apps/org.wezfurlong.wezterm.png
      install -Dm644 assets/wezterm.desktop $out/share/applications/org.wezfurlong.wezterm.desktop
      install -Dm644 assets/wezterm.appdata.xml $out/share/metainfo/org.wezfurlong.wezterm.appdata.xml

      install -Dm644 assets/shell-integration/wezterm.sh -t $out/etc/profile.d
      installShellCompletion --cmd wezterm \
        --bash assets/shell-completion/bash \
        --fish assets/shell-completion/fish \
        --zsh assets/shell-completion/zsh

      install -Dm644 assets/wezterm-nautilus.py -t $out/share/nautilus-python/extensions
    '';

    preFixup = ''
      patchelf --add-needed "${libGL}/lib/libEGL.so.1" $out/bin/wezterm-gui
    '';
  };

  passthru = {
    tests = {
      all-terminfo = nixosTests.allTerminfo;
      terminal-emulators = nixosTests.terminal-emulators.wezterm;
    };
    terminfo = runCommand "wezterm-terminfo"
      {
        nativeBuildInputs = [
          ncurses
        ];
      } ''
      mkdir -p $out/share/terminfo $out/nix-support
      tic -x -o $out/share/terminfo ${src}/termwiz/data/wezterm.terminfo
    '';
  };
}
