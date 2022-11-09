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
  version = "20221108-c71e22e57db676c412a081698e1ca1f645cde1ea";

  src = fetchFromGitHub {
    owner = "wez";
    repo = pname;
    rev = "c71e22e57db676c412a081698e1ca1f645cde1ea";
    fetchSubmodules = true;
    sha256 = "sha256-D049+JIjvHJaYFFH1NHQ96EWX7CvjnPKjAs0m40x0Dc=";
  };

  cargoSha256 = "sha256-SFyaDwUJbDIFGPMqfwUvRZuCVMb1M7IfKOEQgF03igk=";

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

