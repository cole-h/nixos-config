{ ... }:

{
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

}
