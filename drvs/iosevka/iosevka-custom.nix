{ stdenv
, lib
, pkgs
, fetchFromGitHub
, nodejs-12_x
, remarshal
, ttfautohint-nox
, otfcc
}:
let
  outputHash = "sha256-D/0uuZKXGJ1LDwKJBKEHeZvaLvSiBoJR5LoNlH+/5Zc=";
  sha256 = "073gr8mc7labkyjdq3j8l6w5w28wyyfgylwx8r9125w9zdarziw4";
  pname = "iosevka-${set}";
  version = "3.6.3";

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

  buildDeps = (import ./. { inherit pkgs; }).package;
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchTarball {
    url = "https://github.com/be5invis/Iosevka/archive/v${version}.tar.gz";
    inherit sha256;
  };

  nativeBuildInputs = [
    nodejs-12_x
    buildDeps
    remarshal
    otfcc
    ttfautohint-nox
  ];

  privateBuildPlanJSON = builtins.toJSON { buildPlans.${pname} = privateBuildPlan; };

  passAsFile = [ "privateBuildPlanJSON" ];

  configurePhase = ''
    ${lib.optionalString (privateBuildPlan != null) ''
      remarshal -i "$privateBuildPlanJSONPath" -o private-build-plans.toml -if json -of toml
    ''}

    ln -s ${buildDeps}/lib/node_modules/iosevka/node_modules .
  '';

  buildPhase = ''
    npm run build --no-update-notifier -- ttf::$pname | cat
  '';

  installPhase = ''
    fontdir="$out/share/fonts/truetype"
    install -d "$fontdir"
    install "dist/$pname/ttf"/* "$fontdir"
  '';

  enableParallelBuilding = true;

  inherit outputHash;
  outputHashAlgo = "sha256";
  outputHashMode = "recursive";
}
