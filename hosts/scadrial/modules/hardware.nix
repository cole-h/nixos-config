{ pkgs, lib, ... }:

{
  # Enable sound.
  sound.enable = true;

  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
  };

  services.jack = {
    jackd = {
      enable = true;
      session = ''
        jack_control dps nperiods 2
        jack_control dps period 2048
        sleep 2
      '';
    };
    # support ALSA only programs via ALSA JACK PCM plugin
    alsa.enable = false;
    # support ALSA only programs via loopback device (supports programs like Steam)
    loopback = {
      enable = true;
      # buffering parameters for dmix device to work with ALSA only semi-professional sound programs
      dmixConfig = ''
        period_size 2048
      '';
    };
  };

  users.users.vin.extraGroups = [ "jackaudio" ];

  # Enable OpenGL.
  hardware.opengl.enable = true;

  # Update microcode to address "Firmware Bug" messages on startup.
  hardware.cpu.intel.updateMicrocode = true;
}
