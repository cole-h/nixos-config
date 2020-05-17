{ fetchFromGitHub
, git
, gnupg
, makeWrapper
, openssl
, stdenv
, libxslt
, docbook_xsl
}:

stdenv.mkDerivation rec {
  pname = "git-crypt";
  version = "unstable-2020-04-28";

  src = fetchFromGitHub {
    owner = "AGWA";
    repo = "git-crypt";
    rev = "7c129cdd3830a55a8611eecf82af08cd3301f7f2";
    sha256 = "0ymnlcr7b0vhmwszhzq39ck99dsj9gvwaiyzvs97qyl65mm82kpr";
  };

  nativeBuildInputs = [
    libxslt
  ];

  buildInputs = [
    openssl
    makeWrapper
  ];

  patchPhase = ''
    substituteInPlace commands.cpp \
      --replace '(escape_shell_arg(our_exe_path()))' '= "git-crypt"'
  '';

  makeFlags = [
    "PREFIX=${placeholder "out"}"
    "ENABLE_MAN=yes"
    "DOCBOOK_XSL=${docbook_xsl}/share/xml/docbook-xsl-nons/manpages/docbook.xsl"
  ];

  postFixup = ''
    wrapProgram $out/bin/git-crypt --prefix PATH : $out/bin:${git}/bin:${gnupg}/bin
  '';
}
