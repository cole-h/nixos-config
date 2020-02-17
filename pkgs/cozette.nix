{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "Cozette";
  version = "1.4.0";

  src = fetchurl {
    url =
      "https://github.com/slavfox/Cozette/releases/download/v.${version}/CozetteVector.ttf";
    # "https://github.com/slavfox/Cozette/releases/download/v.${version}/cozette.otb";
    sha256 = "1f098z7lrj3kgb5kp2033gvjr8lsy7dwy84cv7y7c0l0d4xyisy4";
    # sha256 = "1xa872a7q5l6i5gn7p4p7cl30i3g3m1512kxa3a9xaj0qgdpdiid";
  };

  phases = [ "installPhase" ];

  installPhase = ''
    # fontdir="$out/share/fonts/opentype/"
    fontdir="$out/share/fonts/truetype/"
    install -d "$fontdir"
    install -m644 $src "$fontdir/CozetteVector.ttf"
    # install -m644 $src "$fontdir/cozette.otb"
  '';
}
