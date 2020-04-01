final: super:
with super;

{
  iosevka-custom = (
    iosevka.override {
      set = "custom";

      privateBuildPlan = {
        hintParams = [ "-a" "sss" ];
        family = "Iosevka Custom";

        weights = {
          thin = {
            shape = 100;
            menu = 100;
            css = 100;
          };

          extralight = {
            shape = 200;
            menu = 200;
            css = 200;
          };

          light = {
            shape = 300;
            menu = 300;
            css = 300;
          };

          regular = {
            shape = 400;
            menu = 400;
            css = 400;
          };

          book = {
            shape = 450;
            menu = 450;
            css = 450;
          };

          medium = {
            shape = 500;
            menu = 500;
            css = 500;
          };

          semibold = {
            shape = 600;
            menu = 600;
            css = 600;
          };

          bold = {
            shape = 700;
            menu = 700;
            css = 700;
          };

          extrabold = {
            shape = 800;
            menu = 800;
            css = 800;
          };

          heavy = {
            shape = 900;
            menu = 900;
            css = 900;
          };
        };

        slants = {
          upright = "normal";
          italic = "italic";
          oblique = "oblique";
        };

        design = [
          "sp-term"
          "v-l-italic"
          "v-i-serifed"
          "v-a-doublestorey"
          "v-f-straight"
          "v-g-singlestorey"
          "v-m-shortleg"
          "v-t-standard"
          "v-q-taily"
          "v-y-straight"
          "v-zero-slashed"
          "v-one-base"
          "v-three-flattop"
          "v-tilde-low"
          "v-asterisk-high"
          "v-paragraph-high"
          "v-caret-high"
          "v-underscore-high"
          "v-at-fourfold"
          "v-eszet-sulzbacher"
          "v-brace-curly"
          "v-dollar-through"
          "v-numbersign-slanted"
          "v-percent-dots"
        ];
      };
    }
  ).overrideAttrs (
    old: {
      installPhase = ''
        fontdir="$out/share/fonts/truetype"

        install -d "$fontdir"
        install dist/$pname/ttf/* "$fontdir"
      '';

      outputHash = "0ygvy89gik2bn52j68kcxxadpll75m1j9bd1qgwiq2a7jm5bwxra";
      outputHashAlgo = "sha256";
      outputHashMode = "recursive";
    }
  );
}
