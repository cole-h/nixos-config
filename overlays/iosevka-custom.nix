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
          "no-ligation"
          "sp-term"
          "v-a-doublestorey"
          "v-asterisk-high"
          "v-at-threefold"
          "v-brace-curly"
          "v-caret-high"
          "v-dollar-through"
          "v-eszet-sulzbacher"
          "v-f-straight"
          "v-g-singlestorey"
          "v-i-serifed"
          "v-lig-ltgteq-slanted"
          "v-l-italic"
          "v-m-shortleg"
          "v-numbersign-slanted"
          "v-one-base"
          "v-paragraph-high"
          "v-percent-dots"
          "v-q-taily"
          "v-three-flattop"
          "v-tilde-low"
          "v-t-standard"
          "v-underscore-high"
          "v-y-straight"
          "v-zero-reverse-slashed"
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

      outputHash = "0y62myxrlc1r8lgr6bbxrxp87k3d041q0rwnqikr68bxh58cf03f";
      outputHashAlgo = "sha256";
      outputHashMode = "recursive";
    }
  );
}
