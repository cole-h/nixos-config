{ lib
}:
let
  stripStore = path:
    let
      plist = builtins.split "/" (builtins.replaceStrings [ "nix" "store" ] [ "" "" ] path);
      plist' = builtins.filter (p: p != "" && p != [ ]) plist;
      store = builtins.head plist';
      filtered = builtins.filter (p: p != store) plist';
      path' = toString filtered;
      path'' = builtins.replaceStrings [ " " ] [ "/" ] path';
    in
    path'';
in
{
  wallpaper = ./wallpaper.png;

  # TODO: find out why I wrote this lol
  toStringHack = root: path:
    "${root}/${stripStore path}";

  scripts =
    let
      stripExtension = s: lib.removeSuffix ".sh" s;

      scripts = builtins.listToAttrs (
        map
          # FIXME: see below message for secrets
          # (file: lib.nameValuePair (stripExtension file) (toString ./scripts + "/${file}"))
          # (builtins.attrNames (builtins.readDir ./scripts))

          (file: lib.nameValuePair (stripExtension file) ("/home/vin/flake/scripts/${file}"))
          (builtins.attrNames (builtins.readDir ./scripts))
      );
    in
    scripts;

  drvs =
    let
      stripExtension = s: lib.removeSuffix ".nix" s;

      drvs = builtins.listToAttrs (
        map
          (file: lib.nameValuePair (stripExtension file) (./nix/drvs + "/${file}"))
          (builtins.attrNames (builtins.readDir ./nix/drvs))
      );
    in
    drvs;
}
