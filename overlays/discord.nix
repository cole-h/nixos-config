final: super:
let
  orig_discord = super.discord;
in
  with super;
  {
    discord = runCommand "discord" { buildInputs = [ makeWrapper ]; }
      ''
        mkdir -p $out/bin
        makeWrapper ${orig_discord}/bin/Discord $out/bin/discord \
          --set "GDK_BACKEND" "x11"
        # ln -s ''${discord}/bin/Discord $out/bin/discord
      '';
  }
