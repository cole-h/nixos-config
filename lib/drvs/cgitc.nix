{ lib, fetchFromGitHub }:
with lib;
let
  cgitcAbbrs = builtins.readFile
    (fetchFromGitHub
      {
        owner = "simnalamburt";
        repo = "cgitc";
        rev = "7141621f64e82e828f5197c7ae43166b745d8d57";
        sha256 = "sha256-Zb8P0paRCsSAsIseVJYSbicecp8pqPP+vHdW5kbI6zc=";
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
