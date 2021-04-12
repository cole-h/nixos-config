{ fetchzip
, buildFHSUserEnv
, zlib
, iana-etc
}:

let
  server = fetchzip {
    stripRoot = false;
    url = "https://download.deemix.app/0:/server/linux-x86_64-latest.zip";
    sha256 = "3CPjm90R0snMzLcXY10mpkslA7ZW6hFW1Xq7dKuKDTc=";
  };
in
buildFHSUserEnv {
  name = "deemix-server";
  multiPkgs = pkgs: [
    zlib
    iana-etc
  ];

  runScript = "${server}/deemix-server";
}
