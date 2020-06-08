{ mkDerivation
, stdenv
, lib
, pkgconfig
, fetchFromGitHub
, qtbase
, qtsvg
, qtmultimedia
, qmake
, boost
, openssl
, wrapQtAppsHook
}:

mkDerivation rec {
  pname = "chatterino2";
  version = "unstable-2020-05-30";

  src = fetchFromGitHub {
    owner = "Chatterino";
    repo = pname;
    rev = "50d669a1af44471f12d3d9cb9b4c91926c3d8b12";
    sha256 = "02pnl7215i83907b54sx19qhyvp9ppqvrlxccn36kbwa39bfhkv9";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    pkgconfig
    qmake
    wrapQtAppsHook
  ];

  buildInputs = [
    boost
    openssl
    qtbase
    qtmultimedia
    qtsvg
  ];

  meta = with lib; {
    description = "A chat client for Twitch chat";
    homepage = "https://github.com/fourtf/chatterino2";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
