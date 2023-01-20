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
  wezterm = callPackage ./drvs/wezterm { };

  # small-ish overrides
  ripgrep = prev.ripgrep.override { withPCRE2 = true; };
  rofi = prev.rofi.override { plugins = [ final.rofi-emoji ]; };
  bash-preexec = prev.bash-preexec.overrideAttrs ({ ... }: { doCheck = false; });

  # larger overrides
  discord = prev.discord.overrideAttrs
    ({ buildInputs ? [ ], postFixup ? "", ... }: {
      buildInputs = buildInputs ++ [
        final.makeWrapper
      ];

      postFixup = postFixup + ''
        makeWrapper $out/bin/Discord $out/bin/discord \
          --set "GDK_BACKEND" "x11"
      '';
    });

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

  mullvad = prev.mullvad.overrideAttrs ({ nativeBuildInputs ? [ ], ... }: {
    nativeBuildInputs = nativeBuildInputs ++ [
      final.git
    ];
  });
}
