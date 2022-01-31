{ inputs, lib, ... }:
let
  inherit (inputs) self;
in
{
  system.configurationRevision = self.rev or "dirty";
  system.nixos.versionSuffix =
    let
      date = builtins.substring 0 8 (self.lastModifiedDate or self.lastModified);
      rev = self.shortRev or "dirty";
    in
    lib.mkForce ".${date}.${rev}-cosmere";
}
