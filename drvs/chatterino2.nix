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

mkDerivation {
  pname = "chatterino2";
  version = "2.2.1";

  src = fetchFromGitHub {
    owner = "Chatterino";
    repo = "chatterino2";
    rev = "63c167f1db085299d35e88c17e761d1c5b5c526c"; # the owners are too 3Head to properly tag releases lmao
    sha256 = "0llz8jpn50dg4ipzv41y5hzx7r2gch2hzypdpkhv516vyx8wmfis";
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
