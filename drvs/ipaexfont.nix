{ fetchzip }:

let
  pname = "ipaexfont";
  ver = "004.01";
in fetchzip rec {
  name = "${pname}-${ver}";

  # https://ipafont.ipa.go.jp/node193
  url = "https://ipafont.ipa.go.jp/IPAexfont/IPAexfont00401.zip";
  sha256 = "00f813nggvklnaby4dgdbm9k0qm969b65wpf65prbg89icjwzx8z";

  # from fetchzip.nix -- I want it install to $out/share/fonts/truetype, so had
  # to copy it here
  postFetch = ''
    unpackDir="$TMPDIR/unpack"
    mkdir "$unpackDir"
    cd "$unpackDir"

    renamed="$TMPDIR/${baseNameOf url}"
    mv "$downloadedFile" "$renamed"
    unpackFile "$renamed"

    fn=$(cd "$unpackDir" && echo *)
    if [ -f "$unpackDir/$fn" ]; then
      mkdir $out
    fi

    mkdir -p "$out/share/fonts/truetype"
    mv "$unpackDir/$fn"/*.ttf "$out/share/fonts/truetype"
  '';
}
