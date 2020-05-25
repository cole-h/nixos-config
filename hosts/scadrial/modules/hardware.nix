{ pkgs, lib, ... }:

{
  # Enable sound.
  sound.enable = true;

  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
    extraConfig = ''
      ## https://github.com/falkTX/Cadence/blob/f94b2d762a67802616e6367581fe6004ba44bc51/data/pulse2jack/play%2Brec.pa
      .fail

      ### Automatically restore the volume of streams and devices
      load-module module-device-restore
      load-module module-stream-restore
      load-module module-card-restore

      ### Load Jack modules
      load-module module-jack-source
      load-module module-jack-sink

      ### Load unix protocol
      load-module module-native-protocol-unix

      ### Automatically restore the default sink/source when changed by the user
      ### during runtime
      ### NOTE: This should be loaded as early as possible so that subsequent modules
      ### that look up the default sink/source get the right value
      load-module module-default-device-restore

      ### Automatically move streams to the default sink if the sink they are
      ### connected to dies, similar for sources
      load-module module-rescue-streams

      ### Make sure we always have a sink around, even if it is a null sink.
      load-module module-always-sink

      ### Make Jack default
      set-default-source jack_in
      set-default-sink jack_out
    '';
  };

  users.users.vin.extraGroups = [ "jackaudio" ];
  services.jack.jackd = {
    enable = true;
    extraOptions = [ "-dalsa" "--period=2048" ];
  };

  # Enable OpenGL.
  hardware.opengl.enable = true;

  # Update microcode to address "Firmware Bug" messages on startup.
  hardware.cpu.intel.updateMicrocode = true;
}
