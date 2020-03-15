final: super:
with super;

{
  redshift-wlr = redshift-wlr.overrideAttrs (old: {
    src = fetchFromGitHub {
      owner = "minus7";
      repo = "redshift";
      rev = "7da875d34854a6a34612d5ce4bd8718c32bec804";
      sha256 = "0nbkcw3avmzjg1jr1g9yfpm80kzisy55idl09b6wvzv2sz27n957";
    };
  });
}
