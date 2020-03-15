{ stdenv, fetchFromGitHub, rustPlatform, fzf }:

rustPlatform.buildRustPackage {
  pname = "zoxide";
  version = "0.2.0";

  src = ~/workspace/vcs/zoxide;

  buildInputs = [
    fzf
  ];

  doCheck = false;

  cargoSha256 = "1gbqg500h4zh706v9l8ww69506z0z6y21pwb61q9lal3cx992mcq";

  meta = with stdenv.lib; {
    description = "A fast cd command that learns your habits";
    homepage = "https://github.com/ajeetdsouza/zoxide";
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ ysndr ];
    platforms = platforms.all;
  };
}
