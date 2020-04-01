{ stdenv
, lib
, fetchgit
, git
, cmake
, ncurses
, libiconv
, pcre2
, coreutils
, gnugrep
, gnused
, python3
, groff
, gettext
, python3Packages
, man-db
}:

stdenv.mkDerivation rec {
  pname = "fish";
  version = "3.1.0";

  src = fetchgit {
    url = "https://github.com/fish-shell/fish-shell.git";
    rev = "0844bcfef1aa37f4895b3cf3ffc94530f87d1e21";
    sha256 = "07knj89riscnxi43pmms2xcnd1ybm0ndasb5lkgmbpyas7p0jrhx";
    deepClone = true;
    leaveDotGit = true;
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ git ncurses libiconv pcre2 ];

  preConfigure = ''
    # git describe --dirty= 2>/dev/null > version
    patchShebangs ./build_tools/git_version_gen.sh
  '';

  # Required binaries during execution
  # Python: Autocompletion generated from manpages and config editing
  propagatedBuildInputs = [
    coreutils
    gnugrep
    gnused
    python3
    groff
    gettext
    python3Packages.sphinx
  ] ++ lib.optional (!stdenv.isDarwin) man-db;

  # postInstall = optionalString useOperatingSystemEtc ''
  #   tee -a $out/etc/fish/config.fish < ${(writeText "config.fish.appendix" etcConfigAppendixText)}
  # '' + ''
  #   tee -a $out/share/fish/__fish_build_paths.fish < ${(writeText "__fish_build_paths_suffix.fish" fishPreInitHooks)}
  # '';

  enableParallelBuilding = true;

  meta = with lib; {
    description = "Smart and user-friendly command line shell";
    homepage = http://fishshell.com/;
    license = licenses.gpl2;
    platforms = platforms.unix;
    maintainers = with maintainers; [ ocharles ];
  };

  passthru = {
    shellPath = "/bin/fish";
  };
}
