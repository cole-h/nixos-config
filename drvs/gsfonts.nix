{ stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "gsfonts";
  version = "20180327";

  src = fetchFromGitHub {
    owner = "ArtifexSoftware";
    repo = "urw-base35-fonts";
    rev = "b758567463df532414c520cf008e27d9448b55a4";
    sha256 = "1k578r3qb0sjfd715jw0bc00pjvbrgnw0b7zrrhk33xghrdvp4r6";
  };

  installPhase = ''
    ls -al
    install -Dt "$out/share/fonts/opentype/${pname}" -m644 fonts/*.otf
    install -Dt "$out/share/metainfo" -m644 appstream/*.xml

    install -d "$out"/etc/fonts/conf.{avail,d}
    for _f in fontconfig/*.conf; do
      _fn="$out/etc/fonts/conf.avail/69-''${_f##*/}"
      install -m644 ''${_f} "''${_fn}"
      ln -srt "$out/etc/fonts/conf.d" "''${_fn}"
    done
  '';
}
