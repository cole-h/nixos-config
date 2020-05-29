{ stdenv
, lib
, fetchurl
, mono
, libmediainfo
, sqlite
, curl
, makeWrapper
}:

stdenv.mkDerivation rec {
  pname = "sonarr";
  version = "3.0.3.834";

  src = fetchurl {
    url = "https://download.sonarr.tv/v3/phantom-develop/${version}/Sonarr.phantom-develop.${version}.linux.tar.gz";
    sha256 = "1f9ka21ni0085anb9c9bz6jlk09ip92phqpgiml9310ws5k0m85x";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    cp -r * $out/bin/

    # makeWrapper "''${mono}/bin/mono" $out/bin/NzbDrone \
    makeWrapper "${mono}/bin/mono" $out/bin/NzbDrone \
      --add-flags "$out/bin/Sonarr.exe" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ curl sqlite libmediainfo ]}
  '';
}
