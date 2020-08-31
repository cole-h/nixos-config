{ lib
, secretDir
}:

{
  wallpaper = toString ./wallpaper.png;

  scripts =
    let
      stripExtension = s: lib.removeSuffix ".sh" s;

      scripts = builtins.listToAttrs (
        map
          # FIXME: see below message for secrets
          # (file: lib.nameValuePair (stripExtension file) (toString ./scripts + "/${file}"))
          # (builtins.attrNames (builtins.readDir ./scripts))

          (file: lib.nameValuePair (stripExtension file) ("/home/vin/.config/nixpkgs/scripts/${file}"))
          # (builtins.attrNames (builtins.readDir "/home/vin/.config/nixpkgs/scripts"))
          (builtins.attrNames (builtins.readDir ./scripts))
      );
    in
    scripts;

  secrets =
    let
      filter = attrs: lib.filterAttrs
        (name: value: !((lib.hasPrefix "." name) || (name == "README.md")))
        attrs;

      secrets = builtins.listToAttrs (
        map
          # FIXME: find a good solution to keeping secrets out of store
          # - using a `secrets` input adds it to the store
          # - using "/home/vin/.config/nixpkgs/secrets" makes it impure
          # (file: lib.nameValuePair file ("${secretDir}/${file}"))
          # (builtins.attrNames (builtins.readDir secretDir))

          # FIXME: impure
          (file: lib.nameValuePair file ("/home/vin/.config/nixpkgs/secrets/${file}"))
          # (builtins.attrNames (builtins.readDir "/home/vin/.config/nixpkgs/secrets"))
          (builtins.attrNames (builtins.readDir secretDir))
      );
    in
    (filter secrets);
}
