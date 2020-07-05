{ stdenv
, fetchurl
, cmake
}:
let
  version = "0.1.3";
in
stdenv.mkDerivation {
  pname = "caps2esc";
  inherit version;

  src = fetchurl {
    url = "https://gitlab.com/interception/linux/plugins/caps2esc/repository/v${version}/archive.tar.gz";
    sha256 = "196yn32wvfkhsd4am4rk72481f3bhmfn7cz7q898ryjs35d54ma0";
  };

  patches = [
    ./remap-esc.patch
  ];

  buildInputs = [ cmake ];
}
