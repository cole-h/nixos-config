{ pkgs, ... }:
{
  users.groups.deploy = { };
  users.users.deploy = {
    isSystemUser = true;
    group = "deploy";
    shell = pkgs.bash;

    openssh.authorizedKeys.keys = [
      ''no-pty ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINMcTaqUZSwv6YW8lx/JhsAZTdNSSC2fR8Pgk8woeFKh vin@scadrial''
      # "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINMcTaqUZSwv6YW8lx/JhsAZTdNSSC2fR8Pgk8woeFKh vin@scadrial"
    ];
  };

  security.doas.extraRules = [
    # { groups = [ "deploy" ]; noPass = true; cmd = "sh"; }
    { groups = [ "deploy" ]; noPass = true; cmd = "sh"; args = [ "-c" ''"readlink -e /nix/var/nix/profiles/system || readlink -e /run/current-system"'' ]; }
    { groups = [ "deploy" ]; noPass = true; cmd = "nix-store"; }
    { groups = [ "deploy" ]; noPass = true; cmd = "nix-env"; }
  ];
}
