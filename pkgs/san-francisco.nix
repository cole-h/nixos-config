{ stdenv, lib, fetchurl, unzip, libarchive }:

stdenv.mkDerivation rec {
  pname = "san-francisco";
  version = "1.0.0.0.1.1497983075";

  src = fetchurl {
    url = "https://developer.apple.com/fonts/downloads/SFPro.zip";
    hash = "sha256:1mivrvbsawy8cpwlmq051s7803y9h4rr6d7lld73l4nh6xl8ad8j";
  };

  phases = [ "unpackPhase" "installPhase" ];

  nativeBuildInputs = [ unzip libarchive ];

  unpackPhase = ''
    unzip $src
    cd SFPro

    mkdir pkg

    bsdtar xvPf 'San Francisco Pro.pkg' 2>/dev/null || true
    bsdtar xvPf 'San Francisco Pro.pkg/Payload'
  '';

  installPhase = ''
    fontdir="$out/share/fonts/opentype"
    install -d "$fontdir"
    install -m644 Library/Fonts/*.otf "$fontdir"

    install -d $out/usr/share/licenses/$pname/
    install -m644 'SF Pro Font License.rtf' $out/usr/share/licenses/$pname/LICENSE.rtf
  '';

  meta = with lib; {
    description = "The system font for macOS, iOS, watchOS, and tvOS.";
    homepage = "https://developer.apple.com/fonts";
    license = licenses.unfree;
    platforms = platforms.linux;
  };
}
