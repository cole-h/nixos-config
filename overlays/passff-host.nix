final: super:
with super;
{
  passff-host = passff-host.overrideAttrs
    ({ ... }: {
        patchPhase = ''
          sed -i 's#COMMAND = "pass"#COMMAND = "${pass-otp}/bin/pass"#' src/passff.py
        '';
      });
}
