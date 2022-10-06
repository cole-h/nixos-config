{ config, pkgs, ... }:

{
  users = {
    mutableUsers = false;

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users = {
      vin = {
        isNormalUser = true;
        uid = 1000;
        shell = pkgs.fish;
        extraGroups = map (k: config.users.groups.${k}.name or k) [
          "adbusers"
          "audio"
          "avahi"
          "dialout" # for mdloader
          "input"
          "keys"
          "kvm"
          "realtime"
          "wheel"
        ];
        # mkpasswd -m sha-512
        hashedPassword = "$6$FaEHrjGo$OaEd7FMHnY4UviCjWbuWS5vG4QNg0CPc5lcYCRjscDOxBA1ss43l8ZYzamCtmjCdxjVanElx45FtYzQ3abP/j0";

        openssh.authorizedKeys.keys = config.users.users.root.openssh.authorizedKeys.keys ++ [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO0cqQLClwMANrKjuC9nKWSjHLS2rcDjW90y/2PqZ0vb u0_a357@localhost"
        ];
      };

      root = {
        hashedPassword = null;

        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC4WeCfgpkFajmCijQBDXPEOLrBPaXDOaV/Mq31g9RDz root@scar"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINMcTaqUZSwv6YW8lx/JhsAZTdNSSC2fR8Pgk8woeFKh vin@scadrial"
        ];
      };
    };
  };
}
