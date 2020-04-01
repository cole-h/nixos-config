{ lib
, callPackage
, makeWrapper
, installShellFiles

, expat
, fontconfig
, freetype
, libGL
, libX11
, libXcursor
, libXi
, libXrandr
, libXxf86vm
, libxcb
, libxkbcommon
, wayland

, gzip
, pkgconfig
, python3
, xdg_utils
, releaseBuild ? true
}:
let
  src = toString ~/workspace/vcs/alacritty;
  sources = import <vin/nix/sources.nix>;
  naersk = callPackage sources.naersk {};
  gitignoreSource = (callPackage sources.gitignore {}).gitignoreSource;
  commitHash = with lib; substring 0 8 (commitIdFromGitRepo "${src}/.git");

  rpathLibs = [
    expat
    fontconfig
    freetype
    libGL
    libX11
    libXcursor
    libXi
    libXrandr
    libXxf86vm
    libxcb
    libxkbcommon
    wayland
  ];
in
(
  naersk.buildPackage {
    name = "alacritty";
    version = commitHash;
    root = gitignoreSource src;
    buildInputs = [
      makeWrapper
      installShellFiles
      gzip
      pkgconfig
      python3
    ] ++ rpathLibs;
    cargoOptions = (opts: opts ++ [ "--locked" ]);
    release = releaseBuild;
    doCheck = false;
  }
).overrideAttrs (
  _: {
    postPatch = ''
      substituteInPlace alacritty/src/config/mouse.rs \
        --replace xdg-open ${xdg_utils}/bin/xdg-open

      sed -i 's@let hash =.*@let hash = "${commitHash}";@' \
        alacritty/build.rs
    '';

    installPhase = ''
      runHook preInstall

      install -D target/${if releaseBuild then "release" else "debug"}/alacritty $out/bin/alacritty

      install -D extra/linux/Alacritty.desktop -t $out/share/applications/
      install -D extra/logo/alacritty-term.svg $out/share/icons/hicolor/scalable/apps/Alacritty.svg
      patchelf --set-rpath "${lib.makeLibraryPath rpathLibs}" $out/bin/alacritty

      installShellCompletion --zsh extra/completions/_alacritty
      installShellCompletion extra/completions/alacritty.{fish,bash}

      install -dm 755 "$out/share/man/man1"
      gzip -c extra/alacritty.man > "$out/share/man/man1/alacritty.1.gz"

      runHook postInstall
    '';

    dontPatchELF = true; # we already did it :)
  }
)
