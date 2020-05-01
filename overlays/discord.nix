final: super:
with super;
let
  orig_discord = discord;
in
{
  discord = runCommand "discord" { buildInputs = [ makeWrapper ]; }
    ''
      mkdir -p $out/bin
      makeWrapper ${orig_discord}/bin/Discord $out/bin/discord \
        --set "GDK_BACKEND" "x11"
    '';
}
