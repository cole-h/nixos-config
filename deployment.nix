let
  sources = import ./nix/sources.nix;
  pinnedPkgs = import sources.nixpkgs { overlays = [ (import ./overlays) ]; };
in
{
  network.description = "Cosmere";
  network.enableRollback = true;
  network.nixpkgs = pinnedPkgs;

  scadrial =
    { ... }:
    {
      imports = [
        ./hosts/scadrial/configuration.nix
        ./options.nix
      ];

      nix.nixPath = [
        "nixpkgs=${pinnedPkgs.path}"
        "nixos-config=/etc/nixos/configuration.nix"
        "/nix/var/nix/profiles/per-user/root/channels"
      ];

      deployment.targetHost = "localhost";
      deployment.privilegeEscalationCommand = [ "doas" ];
    };
}
