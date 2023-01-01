{ config, pkgs, ... }:

{
  users = {
    mutableUsers = false;

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users = {
      slammer = {
        isNormalUser = true;
        uid = 1000;
        shell = pkgs.fish;
        extraGroups = [ "wheel" ];
        # mkpasswd -m sha-512
        hashedPassword = "$6$KJrI5gCcDFqIvWUi$2/NxO/Xdq1M1/ED6e.4.iK.tQBuSLd0yqb7ut9yCwuhKfKf841.EoZQpaYrm8uqEcLRBhdCQVNcZUYT22zr2B.";

        openssh.authorizedKeys.keys = config.users.users.root.openssh.authorizedKeys.keys ++ [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO0cqQLClwMANrKjuC9nKWSjHLS2rcDjW90y/2PqZ0vb u0_a357@localhost"
        ];
      };

      root = {
        hashedPassword = null;

        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINMcTaqUZSwv6YW8lx/JhsAZTdNSSC2fR8Pgk8woeFKh vin@scadrial"
        ];
      };
    };
  };
}
