lib:

{
  wallpaper = toString ./wallpaper.png;

  scripts =
    let
      stripExtension = s: lib.removeSuffix ".sh" s;

      scripts = builtins.listToAttrs (
        map
          # FIXME: see below message for secrets
          # (file: lib.nameValuePair (stripExtension file) (toString ./scripts + "/${file}"))

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

      secrets = builtins.listToAttrs (
        map
          # FIXME: refers to store path because repo is imported before the
          # Nix is parsed -- modifying secrets necessitates a redeploy
          # (file: lib.nameValuePair file (toString ./secrets + "/${file}"))
          # (builtins.attrNames (builtins.readDir ./secrets))

          # FIXME: Replace /home/vin/.config with a variable that's always right
          # maybe get config.xdg.configHome into scope (from h-m)
          (file: lib.nameValuePair file ("/home/vin/.config/nixpkgs/secrets/${file}"))
          (builtins.attrNames (builtins.readDir "/home/vin/.config/nixpkgs/secrets"))
      );
    in
    (filter secrets);
}
