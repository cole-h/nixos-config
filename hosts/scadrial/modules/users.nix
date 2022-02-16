{ config, pkgs, ... }:

{
  users = {
    mutableUsers = false;

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users = {
      vin = {
        isNormalUser = true;
        uid = 1000;
        shell = pkgs.zsh;
        extraGroups = map (k: config.users.groups.${k}.name or k) [
          "wheel"
          "audio"
          "input"
          "avahi"
          "realtime"
          "dialout" # for mdloader
          "adbusers"
          "keys"
        ];
        # mkpasswd -m sha-512
        hashedPassword = "$6$FaEHrjGo$OaEd7FMHnY4UviCjWbuWS5vG4QNg0CPc5lcYCRjscDOxBA1ss43l8ZYzamCtmjCdxjVanElx45FtYzQ3abP/j0";

        openssh.authorizedKeys.keys = config.users.users.root.openssh.authorizedKeys.keys ++ [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDaAvSgtLRx3PFzZz9zOAS7I1WYaAdlbC2Pg7jzBiN1uYSoHmoAbCyA/MsyACl3xRQD93Pksw5jRw9U+Mhjuy3wz2uRIu2SVv6uhznanzBknj1L+ozfjuerx6+YHPirjoICq7t/a7KLvcK/EOmDQipd4HLrMKfHXncfFpZK57cXZOk/xu42nHbfWtpS78FBewm5LSwSZrPEBHeZxsVK2ksC+512yR9RtYKq7lP4GpW/Kdu/fyQIQN033G7MXWOaFIiqiq5Onm6RJPYK645YK0/AYc0zALtJC0/kJwbSpoYd6o6Res3QU9uNIX/90g3tefMTqU6LXoLVwgJY4B6Gp3A9t+sn/aFXRtpVJGIAhNoBLSfp7ydvTbZwh5EUKmwZTmkjGyFoAL+bxxsBARlvWIP0riqbCcDRkeURd9wMe72hy+xAtw5C7tw6JX9Ge5gBGyotAUubQRcfCEYj+DJOTl10nG7Vs/rFA6ZVB6/PsXP6JeM+OXaT02dQ8pvnaYg3+3Vodz+rKj+hN5R7zX+zWeGEB1haxcSBcmgIco2F5uwbk+GOx2Ld4Us1rwAa3BzDnJiqYtWXIkbEOfgH+OsXcH++3LzNnVLPHkcOemyMDbUmTTmdhNg/jS3a1xMwcWZZBBpHzl02U5ewWTHyWObkHkDRgzkO6dd0IiO5XEJETwt/yw== u0_a460@localhost"
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
