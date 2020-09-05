# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./modules
  ];

  # link directories doesn't work
  # environment.persistence."/media".link.directories = [
  #   "/asdf"
  # ];

  # bind files doesn't work
  # environment.persistence."/media".bind.files = [
  #   "/jkl"
  # ];

  # home-manager = {
  #   users.vin = import ../../home.nix;
  #   useGlobalPkgs = true;
  #   useUserPackages = true;
  #   verbose = true;
  # };

  nix.package = lib.mkDefault pkgs.nixUnstable;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # TODO: JP fonts and IME
  # omg color emoji finally <-- fucking JK, after updating nixpkgs again, it all came undone.
  # I fucking hate fontconfig
  # fonts.fontconfig.localConf = ''
  #   <?xml version="1.0"?>
  #   <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
  #   <fontconfig>
  #     <!-- Priority:
  #          1. The generic family OR specific family
  #          2. The emoji font family (defined in 60-generic.conf)
  #          3. All the rest
  #     -->
  #     <alias binding="weak">
  #       <family>monospace</family>
  #       <prefer>
  #         <family>emoji</family>
  #       </prefer>
  #     </alias>
  #     <alias binding="weak">
  #       <family>sans-serif</family>
  #       <prefer>
  #         <family>emoji</family>
  #       </prefer>
  #     </alias>

  #     <alias binding="weak">
  #       <family>serif</family>
  #       <prefer>
  #         <family>emoji</family>
  #       </prefer>
  #     </alias>

  #     <selectfont>
  #       <rejectfont>
  #         <!-- Reject DejaVu fonts, they interfere with color emoji. -->
  #         <pattern>
  #           <patelt name="family">
  #             <string>DejaVu Sans</string>
  #           </patelt>
  #         </pattern>
  #         <pattern>
  #           <patelt name="family">
  #             <string>DejaVu Serif</string>
  #           </patelt>
  #         </pattern>
  #         <pattern>
  #           <patelt name="family">
  #             <string>DejaVu Sans Mono</string>
  #           </patelt>
  #         </pattern>

  #         <!-- Also reject EmojiOne Mozilla and Twemoji Mozilla; I want Noto Color Emoji -->
  #         <pattern>
  #           <patelt name="family">
  #             <string>EmojiOne Mozilla</string>
  #           </patelt>
  #         </pattern>
  #         <pattern>
  #           <patelt name="family">
  #             <string>Twemoji Mozilla</string>
  #           </patelt>
  #         </pattern>
  #       </rejectfont>
  #     </selectfont>
  #   </fontconfig>
  # '';

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  ## nix
  nix = {
    trustedUsers = [ "vin" ];
    autoOptimiseStore = true;
    binaryCaches = [
      "https://cache.qyliss.net"
      "https://cole-h.cachix.org"
      "https://passrs.cachix.org"
      "https://nixpkgs-wayland.cachix.org"
    ];

    binaryCachePublicKeys = [
      "qyliss-x220:bZQtoCyr68idLFb8UQeDjnjitO/xAj52gOo9GoKZuog="
      "cole-h.cachix.org-1:qmEJ4uAe5tWwFxU/U5T/Nf2+wzXM3/rCP0SIGbK0dgU="
      "passrs.cachix.org-1:qEBRtLoyRFMZC8obhs0JjUW95PVaPYAUvixVPt6Qsa0="
      "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
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
