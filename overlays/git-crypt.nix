final: super:
with super;

{
  git-crypt = git-crypt.overrideAttrs (old: {
    src = fetchFromGitHub {
      owner = "AGWA";
      repo = old.pname;
      rev = "89bcafa1a6f2643492a2f6c60525fe1a3c0ecc85";
      sha256 = "17rpc11rqfm9q1lknh66q5lj5jk2ayhhpn3y7qdy93v68mnr43q2";
    };
  });
}
