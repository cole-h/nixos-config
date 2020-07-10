{ stdenv
, lib
, fetchurl
, mono
, libmediainfo
, sqlite
, curl
, makeWrapper
}:
let
  version = "3.0.3.896";
in
stdenv.mkDerivation {
  pname = "sonarr";
  inherit version;

  src = fetchurl {
    url = "https://download.sonarr.tv/v3/phantom-develop/${version}/Sonarr.phantom-develop.${version}.linux.tar.gz";
    sha256 = "0swn46dw0wrjknfa9yskx91384ri2hq2rkfzqw198q1pj5f8h5d0";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    cp -r * $out/bin/

    makeWrapper "${mono}/bin/mono" $out/bin/NzbDrone \
      --add-flags "$out/bin/Sonarr.exe" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ curl sqlite libmediainfo ]}
  '';
}
