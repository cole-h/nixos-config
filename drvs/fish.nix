{ stdenv
, lib
, fetchFromGitHub
, coreutils
, utillinux
, which
, gnused
, gnugrep
, groff
, man-db
, getent
, libiconv
, pcre2
, gettext
, ncurses
, python3
, cmake

, runCommand
, writeText
, nixosTests
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

  version = "3.1.2-git";

  rev = "4a352484659b1b513190a5c288653b982c6ad43a";
  sha256 = "0f0xh6jgl57cmkq2ljgi6n2b16c8jd1frj9gcy936837pyx8jrz6";

  fish = stdenv.mkDerivation {
    pname = "fish";
    inherit version;

    src = fetchFromGitHub {
      owner = "fish-shell";
      repo = "fish-shell";
      inherit rev sha256;
    };

    # We don't have access to the codesign executable, so we patch this out.
    # For more information, see: https://github.com/fish-shell/fish-shell/issues/6952
    patches = lib.optional stdenv.isDarwin ./dont-codesign-on-mac.diff;

    nativeBuildInputs = [
      cmake
      python3.pkgs.sphinx # for documentation generation
    ];

    buildInputs = [
      ncurses
      libiconv
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

    # Required binaries during execution
    # Python: Autocompletion generated from manpages and config editing
    propagatedBuildInputs = [
      coreutils
      gnugrep
      gnused
      python3
      groff
      gettext
    ] ++ lib.optional (!stdenv.isDarwin) man-db;

    postInstall = with lib; ''
      sed -i "s|/usr/local/sbin /sbin /usr/sbin||" \
             $out/share/fish/completions/{sudo.fish,doas.fish}

      cat > $out/share/fish/functions/__fish_anypython.fish <<EOF
      function __fish_anypython
          echo ${python3.interpreter}
          return 0
      end
      EOF
    '' + optionalString useOperatingSystemEtc ''
      tee -a $out/etc/fish/config.fish < ${etcConfigAppendix}
    '' + ''
      tee -a $out/share/fish/__fish_build_paths.fish < ${fishPreInitHooks}
    '';

    enableParallelBuilding = true;

    meta = with lib; {
      description = "Smart and user-friendly command line shell";
      homepage = "http://fishshell.com/";
      license = licenses.gpl2;
      platforms = platforms.unix;
      maintainers = with maintainers; [ ocharles cole-h ];
    };

    passthru = {
      shellPath = "/bin/fish";
      tests = {
        nixos = nixosTests.fish;

        # Test the fish_config tool by checking the generated splash page.
        # Since the webserver requires a port to run, it is not started.
        fishConfig =
          let fishScript = writeText "test.fish" ''
            set -x __fish_bin_dir ${fish}/bin
            echo $__fish_bin_dir
            cp -r ${fish}/share/fish/tools/web_config/* .
            chmod -R +w *

            # if we don't set `delete=False`, the file will get cleaned up
            # automatically (leading the test to fail because there's no
            # tempfile to check)
            sed -e "s@, mode='w'@, mode='w', delete=False@" -i webconfig.py

            # we delete everything after the fileurl is assigned
            sed -e '/fileurl =/q' -i webconfig.py
            echo "print(fileurl)" >> webconfig.py

            # and check whether the message appears on the page
            cat (${python3}/bin/python ./webconfig.py \
              | tail -n1 | sed -ne 's|.*\(/build/.*\)|\1|p' \
            ) | grep 'a href="http://localhost.*Start the Fish Web config'

            # cannot test the http server because it needs a localhost port
          '';
          in
          runCommand "test-web-config"
            { } ''
            HOME=$(mktemp -d)
            ${fish}/bin/fish ${fishScript} && touch $out
          '';
      };
    };
  };
in
fish
