# https://github.com/water-sucks/nixed/blob/2479e041a5c6af2fbe191af383abe49c75113c42/pkgs/applications/audio/tidal-hifi/default.nix#L1
{ lib
, stdenv
  # , fetchFromGitHub
, fetchurl
, dpkg
, glibc
, gcc-unwrapped
, autoPatchelfHook
, makeWrapper
, nodePackages
, electron
, nss
, gdk-pixbuf
, libXext
, libxcb
, libXrandr
, libXdamage
, libXcursor
, libXcomposite
, libXtst
, alsa-lib
, pango
, expat
, gtk3-x11
, libXScrnSaver
}:

let
  deps = [
    nss
    gdk-pixbuf
    libXext
    libxcb
    libXrandr
    libXdamage
    libXcursor
    libXcomposite
    libXtst
    alsa-lib
    pango
    expat
    gtk3-x11
    # libXScrnSaver
  ];
in
stdenv.mkDerivation rec {
  pname = "tidal-hifi";
  version = "2.7.1";

  src = fetchurl {
    url = "https://github.com/Mastermindzh/tidal-hifi/releases/download/2.7.1/tidal-hifi_2.7.1_amd64.deb";
    sha256 = "0ua6Wd1OzC1+eKko8HcOsKDkEDfanTBsUHLmZLR7GZk=";
  };
  # src = fetchFromGitHub {
  #   owner = "Mastermindzh";
  #   repo = "tidal-hifi";
  #   rev = version;
  #   sha256 = "g5oShVOVA5Ve/XcMya7mFMsWGy7REEu8MrHenLrAskU=";
  # };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    dpkg
    nodePackages.asar
  ];

  buildInputs = [
    # stdenv.cc.cc
  ] ++ deps;

  sourceRoot = ".";

  unpackCmd = "dpkg-deb -x $src .";

  postPatch = ''
    asar e opt/tidal-hifi/resources/app.asar app
    autoPatchelf app
    asar p app opt/tidal-hifi/resources/app.asar
  '';

  installPhase = ''
    mkdir -p $out/bin

    cp -r usr/share $out/share;
    cp -r opt/tidal-hifi/resources $out/share/tidal-hifi

    substituteInPlace $out/share/applications/tidal-hifi.desktop \
      --replace /opt/tidal-hifi/tidal-hifi $out/bin/tidal-hifi

    makeWrapper ${electron}/bin/electron $out/bin/tidal-hifi \
      --add-flags $out/share/tidal-hifi/app.asar
  '';

  meta = with lib; {
    description = "An Electron wrapper around TIDAL's web version";
    homepage = "https://github.com/Mastermindzh/tidal-hifi";
    license = licenses.bsd3;
    platforms = [ "x86_64-linux" ];
  };
}
