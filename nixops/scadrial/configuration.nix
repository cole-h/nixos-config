# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

# TODO: sort this file
# TODO: add tranmission, sonarr, radarr
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./libvirt
  ];

  nix.trustedUsers = [ "vin" ];
  nix.autoOptimiseStore = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "zfs" ];
  boot.initrd.kernelModules = [ "nouveau" ];
  boot.kernelModules = [ "vfio-pci" ];
  # boot.tmpOnTmpfs = true;
  # TODO: encrypt zfs dataset lol
  # boot.zfs.requestEncryptionCredentials = true;

  boot.kernel.sysctl = {
    "kernel.sysrq" = 1;
  };

  boot.kernelParams = [
    "intel_iommu=on"
    "iommu=pt"
    "intel_iommu=igfx_off"
    "kvm.ignore_msrs=1"
  ];

  networking.hostName = "scadrial"; # Define your hostname.
  networking.hostId = "1bb11552"; # Required for ZFS.
  networking.useDHCP = false;
  networking.nameservers = [ "192.168.1.212" "8.8.8.8" ];
  networking.defaultGateway = "192.168.1.1";
  networking.interfaces.enp3s0.ipv4 = {
    addresses = [
      {
        address = "192.168.1.22";
        # address = "192.168.1.23";
        prefixLength = 24;
      }
    ];
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # TODO: some of these might be part of modules/services
  environment.systemPackages = with pkgs; [
    # alsaUtils
    bc
    binutils
    borgbackup
    # bridge_utils # maybe unnecessary
    # cryptsetup + ntfs3g for external
    dnsutils
    e2fsprogs
    ffmpeg
    file
    gdb
    git
    # glibc/musl # ldd
    htop
    imagemagick
    # iproute # maybe default?
    # iputils # maybe default?
    # kmod # maybe default?
    libarchive # maybe atool?
    libguestfs
    # libreoffice
    lsof
    neovim
    netcat-openbsd
    openssl
    pciutils
    psmisc
    usbutils
    xdg_utils
  ];

  # List services that you want to enable:

  # services.zfs.trim.enable = true; # for zfs on ssd

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  programs.gnupg.agent = {
    enable = true;
    enableBrowserSocket = true;
    enableExtraSocket = true;
    enableSSHSupport = true;
    pinentryFlavor = "gtk2";
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    drivers = with pkgs; [ gutenprint ];
  };

  # Necessary for discovering network printers.
  services.avahi = {
    enable = true;
    nssmdns = true;
  };

  # Enable sound.
  sound.enable = true;

  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
  };

  # I use cadence to start jack, which wants to manage its own pulseaudio.
  systemd.user = {
    services.pulseaudio.enable = lib.mkForce false;
    sockets.pulseaudio.enable = lib.mkForce false;
  };

  # Enable OpenGL.
  hardware.opengl.enable = true;

  # Update microcode to address "Firmware Bug" messages on startup.
  hardware.cpu.intel.updateMicrocode = true;

  # Enable `doas`, a `sudo` replacement.
  security.doas = {
    enable = true;
    extraRules = [
      { groups = [ "wheel" ]; keepEnv = true; persist = true; }
    ];
  };

  security.pam.services.swaylock = { };

  users.mutableUsers = false;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.vin = {
    isNormalUser = true;
    uid = 1000;
    shell = pkgs.fish;
    extraGroups = [ "wheel" "audio" "input" "avahi" "realtime" "libvirtd" ];
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

  programs.fish.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?
}
