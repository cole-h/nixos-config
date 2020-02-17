{ stdenv, lib, fetchurl, p7zip }:

stdenv.mkDerivation rec {
  version = "0.10.2";
  name = "sarasa-gothic";

  src = fetchurl {
    url =
      "https://github.com/be5invis/Sarasa-Gothic/releases/download/v${version}/sarasa-gothic-ttc-${version}.7z";
    sha256 = "05id15j7ylrli053rpl5mad3xy2c950amnbqahn9h3l4d649k3w8";
  };

  phases = [ "unpackPhase" ];

  unpackPhase = ''
    ${p7zip}/bin/7z x $src -o$out/share/fonts/truetype
  '';

  meta = with lib; {
    description =
      "SARASA GOTHIC is a Chinese & Japanese programming font based on Iosevka and Source Han Sans";
    homepage = "https://github.com/be5invis/Sarasa-Gothic";
    license = licenses.ofl;
    maintainers = with maintainers; [ ChengCat ];
    platforms = platforms.all;
  };
}
