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
        index 90a88d4..4894b80 100644
        --- a/ucm2/USB-Audio/USB-Audio.conf
        +++ b/ucm2/USB-Audio/USB-Audio.conf
        @@ -50,7 +50,8 @@ If.realtek-alc4080 {
         		# 0db0:a47c MSI MEG X570S Ace Max
         		# 0db0:b202 MSI MAG Z690 Tomahawk Wifi
         		# 0db0:d6e7 MSI MPG X670E Carbon Wifi
        -		Regex "USB((0414:a00e)|(0b05:(1996|1a(16|2[07])))|(0db0:(005a|151f|1feb|419c|82c7|a073|a47c|b202|d6e7)))"
        +		# 0db0:6c09 MSI MPG Z790 Carbon Wifi
        +		Regex "USB((0414:a00e)|(0b05:(1996|1a(16|2[07])))|(0db0:(6c09|005a|151f|1feb|419c|82c7|a073|a47c|b202|d6e7)))"
         	}
         	True.Define.ProfileName "Realtek/ALC4080"
         }
      '')
    ];
  });
}
