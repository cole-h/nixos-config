final: super:

{
  iosevka-custom = (super.iosevka.override {
    privateBuildPlan = {
      family = "Iosevka Custom";

      design = [
        "v-l-serifed"
        "v-i-serifed"
        "v-a-doublestorey"
        "v-f-straight"
        "v-g-doublestorey"
        "v-m-shortleg"
        "v-t-standard"
        "v-q-taily"
        "v-y-straight"
        "v-zero-slashed"
        "v-one-hooky"
        "v-three-twoarks"
        "v-tilde-low"
        "v-asterisk-high"
        "v-paragraph-high"
        "v-caret-high"
        "v-underscore-high"
        "v-at-long"
        "v-eszet-sulzbacher"
        "v-brace-curly"
        "v-dollar-through"
        "v-numbersign-upright"
        "v-percent-dots"
      ];
    };

    set = "custom";
  }).overrideAttrs (_: {
    installPhase = ''
      fontdir="$out/share/fonts/truetype"
      install -d "$fontdir"
      install dist/$pname/ttf/* "$fontdir"
    '';
  });
}
