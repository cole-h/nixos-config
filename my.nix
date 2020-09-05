{ lib
, secrets
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
  wallpaper = toString ./wallpaper.png;

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

          (file: lib.nameValuePair (stripExtension file) ("/home/vin/.config/nixpkgs/scripts/${file}"))
          (builtins.attrNames (builtins.readDir ./scripts))
      );
    in
    scripts;

  secrets =
    let
      filter = attrs: lib.filterAttrs
        (name: value: !((lib.hasPrefix "." name) || (name == "README.md")))
        attrs;

      secrets' = builtins.listToAttrs (
        map
          # FIXME: find a good solution to keeping secrets out of store
          # - using a `secrets` input adds it to the store
          # - using "/home/vin/.config/nixpkgs/secrets" makes it impure
          # (file: lib.nameValuePair file ("${secretDir}/${file}"))
          # (builtins.attrNames (builtins.readDir secretDir))

          (file: lib.nameValuePair file ("/home/vin/.config/nixpkgs/secrets/${file}"))
          (builtins.attrNames (builtins.readDir secrets))
      );
    in
    (filter secrets');

  drvs =
    let
      stripExtension = s: lib.removeSuffix ".nix" s;

      drvs = builtins.listToAttrs (
        map
          (file: lib.nameValuePair (stripExtension file) (./drvs + "/${file}"))
          (builtins.attrNames (builtins.readDir ./drvs))
      );
    in
    drvs;
}
