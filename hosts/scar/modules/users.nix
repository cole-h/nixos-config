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
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDaAvSgtLRx3PFzZz9zOAS7I1WYaAdlbC2Pg7jzBiN1uYSoHmoAbCyA/MsyACl3xRQD93Pksw5jRw9U+Mhjuy3wz2uRIu2SVv6uhznanzBknj1L+ozfjuerx6+YHPirjoICq7t/a7KLvcK/EOmDQipd4HLrMKfHXncfFpZK57cXZOk/xu42nHbfWtpS78FBewm5LSwSZrPEBHeZxsVK2ksC+512yR9RtYKq7lP4GpW/Kdu/fyQIQN033G7MXWOaFIiqiq5Onm6RJPYK645YK0/AYc0zALtJC0/kJwbSpoYd6o6Res3QU9uNIX/90g3tefMTqU6LXoLVwgJY4B6Gp3A9t+sn/aFXRtpVJGIAhNoBLSfp7ydvTbZwh5EUKmwZTmkjGyFoAL+bxxsBARlvWIP0riqbCcDRkeURd9wMe72hy+xAtw5C7tw6JX9Ge5gBGyotAUubQRcfCEYj+DJOTl10nG7Vs/rFA6ZVB6/PsXP6JeM+OXaT02dQ8pvnaYg3+3Vodz+rKj+hN5R7zX+zWeGEB1haxcSBcmgIco2F5uwbk+GOx2Ld4Us1rwAa3BzDnJiqYtWXIkbEOfgH+OsXcH++3LzNnVLPHkcOemyMDbUmTTmdhNg/jS3a1xMwcWZZBBpHzl02U5ewWTHyWObkHkDRgzkO6dd0IiO5XEJETwt/yw== u0_a460@localhost"
        ];
      };

      root = {
        hashedPassword = null;

        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH6wCrUu1DHKFqeiRxNvIvv41rE5zS9rdingyKtZX5gy openpgp:0xF208643A"
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDD4tjx4CFZ6X1ap4oNB9oI/UVPO8cbJ/ypsbsVQN6x/LwFtHjzdtQiL3pTPyfAFI50bEI09/r0arar5D2eY6Ll+G24jJqY6yQ0qaVNVo77OTsyBaRf8fv+i6sGM0OWHTtIIND9lmb2cuTyEK3ar5pPyHXpLSSyRQSZ3z6/jU5PujjsC9RgFYk9afOqOm/7i6V+dNRC7j2j92c85yERdb9XSpgQYyKtrYi+AmohvaL4NKg2DjXQNTGPrmAPF/Ow5OY+PiBEewiTJ41if3KGZY+eVL48RWmrR5CzykGuhdoTMX1/0kFsRNdsFXhC4KNh/xrhFqkRT5l4udBGeLaH/mlW9TRO/sp8eif64cuS1N1zg5/PSzUM45mmG2OaxKRIEevQBoyCshZt+mc3oSEfdyg0G1mrMmlxmdcq/x+aE3N4nn/bjWcVNByjpXgEPAhV+cPWJM3XZASXcoEEA9Fp7I218zwKnFxNdORoLs9NlE75ScQs5KJz9e0bDlaQZ+VTgOpwGGUalF9GyMNCX7Fpqb7CGEJMJfxFNrFPx9EYaHqxDtxa0wfumWmedLhzfjmyrBA2B+8eaOEChAcGIeqVbZE0u+sY1iibdV7mzcRLfX4WhkFWff4KKjCTFVvJKcd/q5kx7cLTiFcwK4GSRPU6Qfu9N0p+0F/kMBVERO+6VLLQgw== openpgp:0x69277DD3"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC4WeCfgpkFajmCijQBDXPEOLrBPaXDOaV/Mq31g9RDz root@scar" # rock64
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINMcTaqUZSwv6YW8lx/JhsAZTdNSSC2fR8Pgk8woeFKh vin@scadrial"
        ];
      };
    };
  };
}
