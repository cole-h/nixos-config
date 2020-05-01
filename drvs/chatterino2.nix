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
  version = "unstable-2020-04-25";

  src = fetchFromGitHub {
    owner = "Chatterino";
    repo = pname;
    rev = "08678628d561c2bc7054b0ae7fcb308243d34e56";
    sha256 = "13dkvcny2m7b6sgqb98kp8yia8yjx8n6gjjjzcvzhhly2p56gm4b";
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

  qtWrapperArgs = [
    "--set QT_XCB_FORCE_SOFTWARE_OPENGL 1"
    "--set QT_QPA_PLATFORM xcb"
  ];

  meta = with lib; {
    description = "A chat client for Twitch chat";
    homepage = "https://github.com/fourtf/chatterino2";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
