# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

# TODO: sort this file
{
  imports = [
    ./hardware-configuration.nix
    ./modules
  ];

  # nixops deploy -I nixpkgs=https://github.com/NixOS/nixpkgs/tarball/70f8ca8da527b835f407ac0976786124f6ea0719
  # ^ for working plymouth w/ zfs and stuff
  nixpkgs.overlays = [
    (final: super: {
      doas = super.doas.overrideAttrs ({ ... }: {
        patches = [
          (final.fetchpatch {
            url = "https://raw.githubusercontent.com/NixOS/nixpkgs/82f897333a1d2e10ae2d1661f8313c493836d334/pkgs/tools/security/doas/0001-add-NixOS-specific-dirs-to-safe-PATH.patch";
            sha256 = "1glndm3410gsbc6c0pgyjisan7ysvwiahf1nva1aihlq6vq3qr7a";
          })
        ];
      });
    })
  ];

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  documentation.dev.enable = true;

  environment.systemPackages = with pkgs; [
    bc
    binutils
    borgbackup
    cntr # used for breakpointHook
    cryptsetup # for borgbackup
    dnsutils
    e2fsprogs
    ffmpeg
    file
    gdb
    git
    htop
    imagemagick
    libarchive # maybe atool?
    # libreoffice
    lsof
    manpages
    neovim
    netcat-openbsd
    openssl
    pciutils
    posix_man_pages
    psmisc
    usbutils
    xdg_utils
  ];

  ## nix
  nix.trustedUsers = [ "vin" ];
  nix.autoOptimiseStore = true;
  nix.binaryCaches = [
    "https://cole-h.cachix.org"
    "https://nixpkgs-wayland.cachix.org"
  ];

  nix.binaryCachePublicKeys = [
    "cole-h.cachix.org-1:qmEJ4uAe5tWwFxU/U5T/Nf2+wzXM3/rCP0SIGbK0dgU="
    "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
  ];

  ## programs
  programs.gnupg.agent = {
    enable = true;
    enableBrowserSocket = true;
    enableExtraSocket = true;
    enableSSHSupport = true;
    pinentryFlavor = "gtk2"; # has TTY fallback
  };

  programs.fish.enable = true;

  # Enable `doas`, a `sudo` replacement.
  security.doas = {
    enable = true;
    extraRules = [
      { groups = [ "wheel" ]; keepEnv = true; persist = true; }
      { groups = [ "wheel" ]; keepEnv = true; noPass = true; cmd = "virsh"; }
    ];
  };

  security.pam.services.swaylock = { };

  # TODO: only need to legacy mount important parts, like root, var, and home --
  # everything else can automount, apparently (thanks LnL)
  # TODO: apparently it has Before=local-fs.target; does this hurt?
  # systemd.services.zfs-mount.requires = [ "zfs-import.target" ];
  # systemd.services.zfs-mount.wantedBy = [ "local-fs.target" ];

  users.mutableUsers = false;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.vin = {
    isNormalUser = true;
    uid = 1000;
    shell = pkgs.fish;
    extraGroups = [ "wheel" "audio" "input" "avahi" "realtime" ];
    # mkpasswd -m sha-512
    hashedPassword = "$6$FaEHrjGo$OaEd7FMHnY4UviCjWbuWS5vG4QNg0CPc5lcYCRjscDOxBA1ss43l8ZYzamCtmjCdxjVanElx45FtYzQ3abP/j0";

    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDD4tjx4CFZ6X1ap4oNB9oI/UVPO8cbJ/ypsbsVQN6x/LwFtHjzdtQiL3pTPyfAFI50bEI09/r0arar5D2eY6Ll+G24jJqY6yQ0qaVNVo77OTsyBaRf8fv+i6sGM0OWHTtIIND9lmb2cuTyEK3ar5pPyHXpLSSyRQSZ3z6/jU5PujjsC9RgFYk9afOqOm/7i6V+dNRC7j2j92c85yERdb9XSpgQYyKtrYi+AmohvaL4NKg2DjXQNTGPrmAPF/Ow5OY+PiBEewiTJ41if3KGZY+eVL48RWmrR5CzykGuhdoTMX1/0kFsRNdsFXhC4KNh/xrhFqkRT5l4udBGeLaH/mlW9TRO/sp8eif64cuS1N1zg5/PSzUM45mmG2OaxKRIEevQBoyCshZt+mc3oSEfdyg0G1mrMmlxmdcq/x+aE3N4nn/bjWcVNByjpXgEPAhV+cPWJM3XZASXcoEEA9Fp7I218zwKnFxNdORoLs9NlE75ScQs5KJz9e0bDlaQZ+VTgOpwGGUalF9GyMNCX7Fpqb7CGEJMJfxFNrFPx9EYaHqxDtxa0wfumWmedLhzfjmyrBA2B+8eaOEChAcGIeqVbZE0u+sY1iibdV7mzcRLfX4WhkFWff4KKjCTFVvJKcd/q5kx7cLTiFcwK4GSRPU6Qfu9N0p+0F/kMBVERO+6VLLQgw== openpgp:0x69277DD3"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDaAvSgtLRx3PFzZz9zOAS7I1WYaAdlbC2Pg7jzBiN1uYSoHmoAbCyA/MsyACl3xRQD93Pksw5jRw9U+Mhjuy3wz2uRIu2SVv6uhznanzBknj1L+ozfjuerx6+YHPirjoICq7t/a7KLvcK/EOmDQipd4HLrMKfHXncfFpZK57cXZOk/xu42nHbfWtpS78FBewm5LSwSZrPEBHeZxsVK2ksC+512yR9RtYKq7lP4GpW/Kdu/fyQIQN033G7MXWOaFIiqiq5Onm6RJPYK645YK0/AYc0zALtJC0/kJwbSpoYd6o6Res3QU9uNIX/90g3tefMTqU6LXoLVwgJY4B6Gp3A9t+sn/aFXRtpVJGIAhNoBLSfp7ydvTbZwh5EUKmwZTmkjGyFoAL+bxxsBARlvWIP0riqbCcDRkeURd9wMe72hy+xAtw5C7tw6JX9Ge5gBGyotAUubQRcfCEYj+DJOTl10nG7Vs/rFA6ZVB6/PsXP6JeM+OXaT02dQ8pvnaYg3+3Vodz+rKj+hN5R7zX+zWeGEB1haxcSBcmgIco2F5uwbk+GOx2Ld4Us1rwAa3BzDnJiqYtWXIkbEOfgH+OsXcH++3LzNnVLPHkcOemyMDbUmTTmdhNg/jS3a1xMwcWZZBBpHzl02U5ewWTHyWObkHkDRgzkO6dd0IiO5XEJETwt/yw== u0_a460@localhost"
    ];
  };

  users.users.root = {
    hashedPassword = null;

    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDD4tjx4CFZ6X1ap4oNB9oI/UVPO8cbJ/ypsbsVQN6x/LwFtHjzdtQiL3pTPyfAFI50bEI09/r0arar5D2eY6Ll+G24jJqY6yQ0qaVNVo77OTsyBaRf8fv+i6sGM0OWHTtIIND9lmb2cuTyEK3ar5pPyHXpLSSyRQSZ3z6/jU5PujjsC9RgFYk9afOqOm/7i6V+dNRC7j2j92c85yERdb9XSpgQYyKtrYi+AmohvaL4NKg2DjXQNTGPrmAPF/Ow5OY+PiBEewiTJ41if3KGZY+eVL48RWmrR5CzykGuhdoTMX1/0kFsRNdsFXhC4KNh/xrhFqkRT5l4udBGeLaH/mlW9TRO/sp8eif64cuS1N1zg5/PSzUM45mmG2OaxKRIEevQBoyCshZt+mc3oSEfdyg0G1mrMmlxmdcq/x+aE3N4nn/bjWcVNByjpXgEPAhV+cPWJM3XZASXcoEEA9Fp7I218zwKnFxNdORoLs9NlE75ScQs5KJz9e0bDlaQZ+VTgOpwGGUalF9GyMNCX7Fpqb7CGEJMJfxFNrFPx9EYaHqxDtxa0wfumWmedLhzfjmyrBA2B+8eaOEChAcGIeqVbZE0u+sY1iibdV7mzcRLfX4WhkFWff4KKjCTFVvJKcd/q5kx7cLTiFcwK4GSRPU6Qfu9N0p+0F/kMBVERO+6VLLQgw== openpgp:0x69277DD3"
    ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?
}
