{ config, pkgs, ... }:

{
  users = {
    mutableUsers = false;

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users = {
      taln = {
        isNormalUser = true;
        uid = 1000;
        shell = pkgs.fish;
        extraGroups = [ "wheel" ];
        # mkpasswd -m sha-512
        hashedPassword = "$6$fipGZSHnH$mV0WgaT.eEbRiNn2.TE68QJexiytDwIEbWoGW.kxOrXxDHn.GGZ6JtA7Fpl1dEYMPmf/Mibrj4kLFoIF6xKjJ1";

        openssh.authorizedKeys.keys = config.users.users.root.openssh.authorizedKeys.keys ++ [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO0cqQLClwMANrKjuC9nKWSjHLS2rcDjW90y/2PqZ0vb u0_a357@localhost"
        ];
      };

      root = {
        hashedPassword = null;

        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC4WeCfgpkFajmCijQBDXPEOLrBPaXDOaV/Mq31g9RDz root@scar" # rock64
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINMcTaqUZSwv6YW8lx/JhsAZTdNSSC2fR8Pgk8woeFKh vin@scadrial"
        ];
      };
    };
  };
}
