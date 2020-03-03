{ lib, fetchFromGitHub }:

let
  cgitcAbbrs = builtins.readFile (fetchFromGitHub {
    owner = "simnalamburt";
    repo = "cgitc";
    rev = "0adb83f765e17dea0fffb83cbdfb576da1400c09";
    sha256 = "0yicd77kphm9xxpcr70wig4rmx68i1byz9ibirk27m9z0s657n1m";
  } + "/abbreviations");

  filterComments = with lib;
    abbrString:
    builtins.filter (f: f != "" && f != " ")
    (forEach (flatten (builtins.split "\n" abbrString)) (x:
      if hasPrefix "#" x then
        ""
      else if hasInfix "#" x then
        if hasInfix " #" x then
          builtins.elemAt (builtins.split " #" x) 0
        else
          builtins.elemAt (builtins.split "#" x) 0
      else
        x));

  stripLeadingWhitespace = with lib;
    string:
    let
      recurse = s:
        let newString = removePrefix " " s;
        in if hasPrefix " " newString then recurse newString else newString;
    in recurse string;

  abbrsToFish = with lib;
    abbrList:
    forEach abbrList (x:
      let
        len = builtins.stringLength (builtins.elemAt (builtins.split " " x) 0);
        abbr = builtins.substring 0 len x;
        contents = stripLeadingWhitespace
          (builtins.substring (len + 1) (builtins.stringLength x) x);
      in { ${abbr} = "${contents}"; });

  abbrevs = abbrsToFish (filterComments cgitcAbbrs);
in { abbrs = builtins.foldl' (x: y: x // y) { } abbrevs; }
