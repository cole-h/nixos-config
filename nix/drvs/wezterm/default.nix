{ stdenv
, rustPlatform
, lib
, fetchFromGitHub
, ncurses
, pkg-config
, python3
, fontconfig
, installShellFiles
, openssl
, libGL
, libX11
, libxcb
, libxkbcommon
, xcbutil
, xcbutilimage
, xcbutilkeysyms
, xcbutilwm
, wayland
, zlib
, nixosTests
, runCommand
}:

rustPlatform.buildRustPackage rec {
  pname = "wezterm";
  # git -c core.abbrev=8 show -s --format=%cd-%h --date=format:%Y%m%d-%H%M%S | wl-copy -n
  version = "20221130-111338-8d8d7d3f";

  src = fetchFromGitHub {
    owner = "wez";
    repo = pname;
    rev = "8d8d7d3ff46e05125c03ed84e734aa3ef52b001b";
    sha256 = "sha256-iuz89ypBU4puzeL7p/h+6II8VvwW/pjkOG09b8dERIA=";
    fetchSubmodules = true;
  };

  cargoSha256 = "sha256-A9XJ4toWmM5qJNvMQ+YoRbZFc7hKKHfc9ies9tGWwBk=";

  # Rust 1.65 does better at enum packing (according to
  # 40e08fafe2f6e5b0c70d55996a0814d6813442ef), but Nixpkgs doesn't have 1.65
  # yet, so skip these tests for now.
  checkFlags = [
    "--skip=escape::action_size"
    "--skip=surface::line::storage::test::memory_usage"
  ];

  postPatch = ''
    echo ${version} > .tag

    # tests are failing with: Unable to exchange encryption keys
    rm -r wezterm-ssh/tests
  '';

  nativeBuildInputs = [
    installShellFiles
    ncurses # tic for terminfo
    pkg-config
    python3
  ];

  buildInputs = [
    fontconfig
    zlib
    libX11
    libxcb
    libxkbcommon
    openssl
    wayland
    xcbutil
    xcbutilimage
    xcbutilkeysyms
    xcbutilwm # contains xcb-ewmh among others
  ];

  buildFeatures = [ "distro-defaults" ];

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

  meta = with lib; {
    description = "A GPU-accelerated cross-platform terminal emulator and multiplexer written by @wez and implemented in Rust";
    homepage = "https://wezfurlong.org/wezterm";
    license = licenses.mit;
    maintainers = with maintainers; [ SuperSandro2000 ];
    platforms = platforms.unix;
  };
}

