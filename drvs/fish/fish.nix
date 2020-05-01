{ stdenv
, lib
, fetchFromGitHub
, writeText
  # nativeBuildInputs
, makeWrapper
, cmake
  # buildInputs
, libiconv
, ncurses
, pcre2
  # propagatedBuildInputs
, coreutils
, gettext
, gnugrep
, gnused
, groff
, less
, man-db
, python3
, utillinux

, useOperatingSystemEtc ? true
}:
let
  etcConfigAppendix = writeText "config.fish.appendix" ''
    ############### ↓ Nix hook for sourcing /etc/fish/config.fish ↓ ###############
    #                                                                             #
    # Origin:
    #     This fish package was called with the attribute
    #     "useOperatingSystemEtc = true;".
    #
    # Purpose:
    #     Fish ordinarily sources /etc/fish/config.fish as
    #        $__fish_sysconfdir/config.fish,
    #     and $__fish_sysconfdir is defined at compile-time, baked into the C++
    #     component of fish. By default, it is set to "/etc/fish". When building
    #     through Nix, $__fish_sysconfdir gets set to $out/etc/fish. Here we may
    #     have included a custom $out/etc/config.fish in the fish package,
    #     as specified, but according to the value of useOperatingSystemEtc, we
    #     may want to further source the real "/etc/fish/config.fish" file.
    #
    #     When this option is enabled, this segment should appear the very end of
    #     "$out/etc/config.fish". This is to emulate the behavior of fish itself
    #     with respect to /etc/fish/config.fish and ~/.config/fish/config.fish:
    #     source both, but source the more global configuration files earlier
    #     than the more local ones, so that more local configurations inherit
    #     from but override the more global locations.

    if test -f /etc/fish/config.fish
      source /etc/fish/config.fish
    end

    #                                                                             #
    ############### ↑ Nix hook for sourcing /etc/fish/config.fish ↑ ###############
  '';

  fishPreInitHooks = writeText "__fish_build_paths_suffix.fish" ''
    # source nixos environment
    # note that this is required:
    #   1. For all shells, not just login shells (mosh needs this as do some other command-line utilities)
    #   2. Before the shell is initialized, so that config snippets can find the commands they use on the PATH
    builtin status --is-login
    or test -z "$__fish_nixos_env_preinit_sourced" -a -z "$ETC_PROFILE_SOURCED" -a -z "$ETC_ZSHENV_SOURCED"
    and test -f /etc/fish/nixos-env-preinit.fish
    and source /etc/fish/nixos-env-preinit.fish
    and set -gx __fish_nixos_env_preinit_sourced 1

    test -n "$NIX_PROFILES"
    and begin
      # We ensure that __extra_* variables are read in $__fish_datadir/config.fish
      # with a preference for user-configured data by making sure the package-specific
      # data comes last. Files are loaded/sourced in encounter order, duplicate
      # basenames get skipped, so we assure this by prepending Nix profile paths
      # (ordered in reverse of the $NIX_PROFILE variable)
      #
      # Note that at this point in evaluation, there is nothing whatsoever on the
      # fish_function_path. That means we don't have most fish builtins, e.g., `eval`.
      # additional profiles are expected in order of precedence, which means the reverse of the
      # NIX_PROFILES variable (same as config.environment.profiles)
      set -l __nix_profile_paths (echo $NIX_PROFILES | tr ' ' '\n')[-1..1]

      set --prepend __extra_completionsdir \
        $__nix_profile_paths"/etc/fish/completions" \
        $__nix_profile_paths"/share/fish/vendor_completions.d"

      set --prepend __extra_functionsdir \
        $__nix_profile_paths"/etc/fish/functions" \
        $__nix_profile_paths"/share/fish/vendor_functions.d"

      set --prepend __extra_confdir \
        $__nix_profile_paths"/etc/fish/conf.d" \
        $__nix_profile_paths"/share/fish/vendor_conf.d"
    end
  '';

  # Required binaries during execution
  # Python: Autocompletion generated from manpages and config editing
  runtimeBinaries = [
    coreutils
    gettext
    gnugrep
    gnused
    groff
    less
    python3
    utillinux

    ## new
    # ncurses
    # als
    # git
  ] ++ lib.optional (!stdenv.isDarwin) man-db;

  rev = "2951c05934c67e6328eac743385423d0126e4a3c";
  sha256 = "1akrk5s8dyw01zv54rcmz5cmvwc4nqr4m7qi1b12f6sgadyqm7d8";
in
stdenv.mkDerivation rec {
  pname = "fish";
  version = "3.1.1-${lib.substring 0 8 rev}";

  src = fetchFromGitHub {
    owner = "fish-shell";
    repo = "fish-shell";
    inherit rev sha256;
  };

  nativeBuildInputs = [
    cmake
    python3.pkgs.sphinx # for documentation generation
    makeWrapper
  ];

  buildInputs = [
    libiconv
    ncurses
    pcre2
  ];

  preConfigure = ''
    echo ${version} > version
    patchShebangs build_tools/git_version_gen.sh
  '';

  preBuild = ''
    # generating documentation wants access to $HOME for some reason, give it a
    # temporary one
    export HOME=$(mktemp -d)
  '';

  postInstall = lib.optionalString useOperatingSystemEtc ''
    tee -a $out/etc/fish/config.fish < ${etcConfigAppendix}
  '' + ''
    tee -a $out/share/fish/__fish_build_paths.fish < ${fishPreInitHooks}

    sed "\@/usr/local/sbin /sbin /usr/sbin@d" \
      -i $out/share/fish/completions/{sudo,doas}.fish
  '';

  # TODO: no wrapping -- only substituting
  postFixup = ''
    wrapProgram $out/bin/fish \
      --prefix PATH : ${lib.makeBinPath runtimeBinaries}
  '';

  enableParallelBuilding = true;

  passthru = {
    shellPath = "/bin/fish";
  };
}
