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
  version = "20230112-223901-67ce66a5";

  src = fetchFromGitHub {
    owner = "wez";
    repo = pname;
    rev = "67ce66a5b9a3c4a4840e790c610e3e9a7bfaecf0";
    sha256 = "sha256-MpJ/w+XL7JLcixSc0P7dJnUu4S9JBcyh/CsOW+1ZTLU=";
    fetchSubmodules = true;
  };

  cargoSha256 = "sha256-XC6wgzoWTwV10H4dCfozoTmmG8q8MsxAhHaMMCC0Nhc=";

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

