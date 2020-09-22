# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
      ./modules
    ];

  # TODO: JP fonts and IME
  # omg color emoji finally jtojnar is the best
  fonts.fontconfig.localConf = ''
    <?xml version="1.0"?>
    <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
    <fontconfig>
      <!-- Priority:
           1. The generic family OR specific family
           2. The emoji font family (defined in 60-generic.conf)
           3. All the rest
      -->
      <alias binding="weak">
        <family>monospace</family>
        <prefer>
          <family>emoji</family>
        </prefer>
      </alias>
      <alias binding="weak">
        <family>sans-serif</family>
        <prefer>
          <family>emoji</family>
        </prefer>
      </alias>

      <alias binding="weak">
        <family>serif</family>
        <prefer>
          <family>emoji</family>
        </prefer>
      </alias>

      <selectfont>
        <rejectfont>
          <!-- Reject DejaVu fonts, they interfere with color emoji. -->
          <pattern>
            <patelt name="family">
              <string>DejaVu Sans</string>
            </patelt>
          </pattern>
          <pattern>
            <patelt name="family">
              <string>DejaVu Serif</string>
            </patelt>
          </pattern>
          <pattern>
            <patelt name="family">
              <string>DejaVu Sans Mono</string>
            </patelt>
          </pattern>

          <!-- Also reject EmojiOne Mozilla and Twemoji Mozilla; I want Noto Color Emoji -->
          <pattern>
            <patelt name="family">
              <string>EmojiOne Mozilla</string>
            </patelt>
          </pattern>
          <pattern>
            <patelt name="family">
              <string>Twemoji Mozilla</string>
            </patelt>
          </pattern>
        </rejectfont>
      </selectfont>
    </fontconfig>
  '';

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?
}
