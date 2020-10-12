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
  version = "3.0.4.975";
  sha256 = "sha256-WrzzjYfZQFD4WkK4Ph4ARSdLXJDpH2Qa+yviyttv6qk=";
in
stdenv.mkDerivation {
  pname = "sonarr";
  inherit version;

  src = fetchurl {
    url = "https://download.sonarr.tv/v3/phantom-develop/${version}/Sonarr.phantom-develop.${version}.linux.tar.gz";
    inherit sha256;
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
