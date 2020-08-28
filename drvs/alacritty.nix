{ lib
, buildPackage
, makeWrapper
, installShellFiles
, src

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
, git
, releaseBuild ? true
}:
let
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
  buildPackage {
    name = "alacritty";
    version = "0.6.0-git";

    inherit src;

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

    override = ({ nativeBuildInputs ? [ ], ... }: {
      nativeBuildInputs = nativeBuildInputs ++ [ git ];
    });
  }
).overrideAttrs ({ ... }: {
  postPatch = ''
    substituteInPlace alacritty/src/config/mouse.rs \
      --replace xdg-open ${xdg_utils}/bin/xdg-open
  '';

  installPhase = ''
    runHook preInstall

    install -D target/${if releaseBuild then "release" else "debug"}/alacritty $out/bin/alacritty

    install -D extra/linux/Alacritty.desktop -t $out/share/applications/
    install -D extra/logo/alacritty-term.svg $out/share/icons/hicolor/scalable/apps/Alacritty.svg

    strip -S $out/bin/alacritty
    patchelf --set-rpath "${lib.makeLibraryPath rpathLibs}" $out/bin/alacritty

    installShellCompletion --zsh extra/completions/_alacritty
    installShellCompletion extra/completions/alacritty.{fish,bash}
    installManPage extra/alacritty.man

    runHook postInstall
  '';

  dontStrip = true;
  dontPatchELF = true; # we already did it :)
})
