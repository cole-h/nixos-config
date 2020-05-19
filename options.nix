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
    wallpaper = mkOptionStr (toString ./wallpaper.png);
  };
}
