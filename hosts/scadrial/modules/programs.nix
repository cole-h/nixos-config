{ ... }:

{
  documentation.dev.enable = true;

  # Needed for "Running GNOME programs outside of GNOME" (see:
  # https://nixos.wiki/wiki/GNOME#Running_GNOME_programs_outside_of_GNOME)
  programs.dconf.enable = true;

  programs.gnupg.agent = {
    enable = true;
    enableBrowserSocket = true;
    enableExtraSocket = true;
    enableSSHSupport = true;
    pinentryFlavor = "gtk2"; # has TTY fallback
  };

  programs.fish.enable = true;

  programs.command-not-found.enable = false;

  # 0. Plug in phone and make sure it's detected
  # 1. adb tcpip 5555
  # 2. Disconnect phone
  # 3. adb connect [ip]
  programs.adb.enable = true;

  programs.iotop.enable = true;
}
