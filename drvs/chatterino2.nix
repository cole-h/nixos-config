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
  version = "unstable-2020-07-19";

  src = fetchFromGitHub {
    owner = "Chatterino";
    repo = "chatterino2";
    rev = "caa11dda3edd717a54f037fda6f2a7dbc9e25dfa";
    sha256 = "167gq0yng3pb6ssczysjb19bhhyp03gm5rlg7nqhrf94rxawd4zq";
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
