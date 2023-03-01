{ inputs }:
final: prev:
let
  inherit (final)
    callPackage
    runCommand
    ;
in
{
  # misc
  xivlauncher = callPackage ./drvs/xivlauncher { };
  wezterm = callPackage ./drvs/wezterm {
    wezterm-flake = inputs.wezterm;
    naersk = final.callPackage inputs.naersk { };
  };

  # small-ish overrides
  rofi = prev.rofi.override { plugins = [ final.rofi-emoji ]; };

  # larger overrides
  # element-desktop = prev.element-desktop.overrideAttrs
  #   ({ buildInputs ? [ ], postFixup ? "", ... }: {
  #     buildInputs = buildInputs ++ [
  #       final.makeWrapper
  #     ];

  #     postFixup = postFixup + ''
  #       wrapProgram $out/bin/element-desktop \
  #         --add-flags '--enable-features=UseOzonePlatform --ozone-platform=wayland'
  #     '';
  #   });

  # vscode = prev.vscode.overrideAttrs
  #   ({ buildInputs ? [ ], postFixup ? "", ... }: {
  #     buildInputs = buildInputs ++ [
  #       final.makeWrapper
  #     ];

  #     postFixup = postFixup + ''
  #       wrapProgram $out/bin/code \
  #         --add-flags "--enable-features=UseOzonePlatform --ozone-platform=wayland"
  #     '';
  #   });

  # _1password-gui = prev._1password-gui.overrideAttrs
  #   ({ buildInputs ? [ ], postFixup ? "", ... }: {
  #     buildInputs = buildInputs ++ [
  #       final.makeWrapper
  #     ];

  #     postFixup = postFixup + ''
  #       wrapProgram $out/bin/1password \
  #         --add-flags "--enable-features=UseOzonePlatform --ozone-platform=wayland"
  #     '';
  #   });

  alsa-ucm-conf = prev.alsa-ucm-conf.overrideAttrs ({ patches ? [ ], ... }: {
    patches = patches ++ [
      # https://github.com/alsa-project/alsa-ucm-conf/pull/267
      (final.writeText "support-my-mobo.patch" ''
        diff --git a/ucm2/USB-Audio/USB-Audio.conf b/ucm2/USB-Audio/USB-Audio.conf
        index 325d48c..a028eb1 100644
        --- a/ucm2/USB-Audio/USB-Audio.conf
        +++ b/ucm2/USB-Audio/USB-Audio.conf
        @@ -41,7 +41,8 @@ If.realtek-alc4080 {
         		# 0db0:1feb MSI Edge Wifi Z690
         		# 0db0:419c MSI MPG X570S Carbon Max Wifi
         		# 0db0:a073 MSI MAG X570S Torpedo Max
        -		Regex "USB((0b05:(1996|1a2[07]))|(0db0:(1feb|419c|a073)))"
        +		# 0db0:6c09 MSI MPG Z790 Cargon Wifi
        +		Regex "USB((0b05:(1996|1a2[07]))|(0db0:(1feb|419c|a073|6c09)))"
         	}
         	True.Define.ProfileName "Realtek/ALC4080"
         }
      '')
    ];
  });
}
