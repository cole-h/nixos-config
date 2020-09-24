{ lib, fetchFromGitHub }:
with lib;
let
  cgitcAbbrs = builtins.readFile
    (fetchFromGitHub
      {
        owner = "simnalamburt";
        repo = "cgitc";
        rev = "6e915441493cce56891e5ec4a7e4b7c189cdcc42";
        sha256 = "1nbd73kl9g8fgmchm5hkhhhk7lx4fbk3408bw0k2k7633br34na6";
      } + "/abbreviations");

  filterComments = abbrString:
    builtins.filter (f: f != "" && f != " ")
      (forEach (flatten (builtins.split "\n" abbrString))
        (x:
          if hasPrefix "#" x then
            ""
          else if hasInfix "#" x then
            if hasInfix " #" x then
              builtins.elemAt (builtins.split " #" x) 0
            else
              builtins.elemAt (builtins.split "#" x) 0
          else
            x
        )
      );

  stripLeadingWhitespace = string:
    let
      recurse = s:
        let
          newString = removePrefix " " s;
        in
        if hasPrefix " " newString then recurse newString else newString;
    in
    recurse string;

  abbrsToFish = abbrList:
    forEach abbrList (x:
      let
        len = builtins.stringLength (builtins.elemAt (builtins.split " " x) 0);
        abbr = builtins.substring 0 len x;
        contents = stripLeadingWhitespace
          (builtins.substring (len + 1) (builtins.stringLength x) x);
      in
      { ${abbr} = "${contents}"; }
    );

  abbrevs = abbrsToFish (filterComments cgitcAbbrs);
in
{
  abbrs = builtins.foldl' (x: y: x // y) { } abbrevs;
}
