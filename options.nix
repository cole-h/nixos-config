{ lib, pkgs, ... }:
with lib;
let
  mkOptionStr = value: mkOption {
    type = types.str;
    default = value;
  };

  mkOptionAttr = value: mkOption {
    type = types.attrsOf types.str;
    default = value;
  };
in
{
  options.my = {
    wallpaper = mkOptionStr (toString ./wallpaper.png);

    scripts =
      let
        stripExtension = s: removeSuffix ".sh" s;

        scripts = listToAttrs (
          map
            (file: nameValuePair (stripExtension file) (toString ./scripts + "/${file}"))
            (attrNames (builtins.readDir ./scripts))
        );
      in
      mkOptionAttr scripts;

    secrets =
      let
        filter = attrs: filterAttrs
          (name: value: !((hasPrefix "." name) || (name == "README.md")))
          attrs;

        secrets = listToAttrs (
          map
            (file: nameValuePair file (toString ./secrets + "/${file}"))
            (attrNames (builtins.readDir ./secrets))
        );
      in
      mkOptionAttr (filter secrets);
  };
}
