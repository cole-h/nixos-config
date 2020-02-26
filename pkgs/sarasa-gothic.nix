{ stdenv, fetchurl, p7zip, mkfontscale }:

stdenv.mkDerivation rec {
  pname = "sarasa-gothic";
  version = "0.10.2";

  src = fetchurl {
    url =
      "https://github.com/be5invis/Sarasa-Gothic/releases/download/v${version}/sarasa-gothic-ttc-${version}.7z";
    sha256 = "05id15j7ylrli053rpl5mad3xy2c950amnbqahn9h3l4d649k3w8";
  };

  nativeBuildInputs = [ mkfontscale ];
  phases = [ "unpackPhase" ];

  unpackPhase = ''
    fontdir="$out/share/fonts/truetype"

    ${p7zip}/bin/7z x $src -o"$fontdir"
    mkfontscale "$fontdir"
  '';

  meta = with stdenv.lib; {
    description = ''
      SARASA GOTHIC is a Chinese & Japanese programming font based on Iosevka
      and Source Han Sans
    '';
    homepage = "https://github.com/be5invis/Sarasa-Gothic";
    license = licenses.ofl;
    platforms = platforms.all;
  };
}
