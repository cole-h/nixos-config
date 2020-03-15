final: super:
with super;

{
  iosevka-custom = (iosevka.override {
    set = "custom";

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
  }).overrideAttrs (_: {
    installPhase = ''
      fontdir="$out/share/fonts/truetype"

      install -d "$fontdir"
      install dist/$pname/ttf/* "$fontdir"
    '';

    outputHash = "1vn1s12imc1g62hjpdr4k7cl82hdn5jvcb192h31alj57d01pwni";
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
  });
}
