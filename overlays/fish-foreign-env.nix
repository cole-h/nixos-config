self: super:

{
  # FIXME: remove after https://github.com/NixOS/nixpkgs/pull/79682
  fish-foreign-env = super.fish-foreign-env.overrideAttrs (_: {
    version = "git-20200209";

    src = super.fetchFromGitHub {
      owner = "oh-my-fish";
      repo = "plugin-foreign-env";
      rev = "dddd9213272a0ab848d474d0cbde12ad034e65bc";
      sha256 = "00xqlyl3lffc5l0viin1nyp819wf81fncqyz87jx8ljjdhilmgbs";
    };
  });
}
