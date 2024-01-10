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
  cgitc = callPackage ./drvs/cgitc.nix { };
  wezterm = callPackage ./drvs/wezterm {
    wezterm-flake = inputs.wezterm;
    naersk = callPackage inputs.naersk { };
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

  _1password-gui = prev._1password-gui.overrideAttrs
    ({ buildInputs ? [ ], postFixup ? "", ... }: {
      buildInputs = buildInputs ++ [
        final.makeWrapper
      ];

      postFixup = postFixup + ''
        wrapProgram $out/bin/1password \
          --unset NIXOS_OZONE_WL
      '';
    });
}
