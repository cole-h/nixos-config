{ stdenv
, lib
, fetchFromGitHub
, writeText
, coreutils
, utillinux
, which
, gnused
, gnugrep
, groff
, gawk
, man-db
, getent
, libiconv
, pcre2
, gettext
, ncurses
, python3
, cmake
}:
let
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

  rev = "1fd9debaad46ffcf689e805b1ab9d79df53c409f";
  hash = "sha256-ghSMqpoI8lWsabQ5M0dXZZTXZ93dI4k3p8yGqSULlKI=";

  fish = stdenv.mkDerivation {
    pname = "fish";
    inherit version;

    src = fetchFromGitHub {
      owner = "fish-shell";
      repo = "fish-shell";
      inherit rev hash;
    };

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
      man-db
    ];

    postInstall = with lib; ''
      sed -r "s|command grep|command ${gnugrep}/bin/grep|" \
          -i "$out/share/fish/functions/grep.fish"
      sed -i "s|which |${which}/bin/which |"               \
             "$out/share/fish/functions/type.fish"
      sed -e "s|\|cut|\|${coreutils}/bin/cut|"             \
          -i "$out/share/fish/functions/fish_prompt.fish"
      sed -e "s|uname|${coreutils}/bin/uname|"             \
          -i "$out/share/fish/functions/__fish_pwd.fish"   \
             "$out/share/fish/functions/prompt_pwd.fish"
      sed -e "s|sed |${gnused}/bin/sed |"                  \
          -i "$out/share/fish/functions/alias.fish"        \
             "$out/share/fish/functions/prompt_pwd.fish"
      sed -i "s|nroff |${groff}/bin/nroff |"               \
             "$out/share/fish/functions/__fish_print_help.fish"
      sed -e "s|clear;|${getBin ncurses}/bin/clear;|"      \
          -i "$out/share/fish/functions/fish_default_key_bindings.fish"
      sed -e "s|python3|${getBin python3}/bin/python3|"    \
          -i $out/share/fish/functions/{__fish_config_interactive.fish,fish_config.fish,fish_update_completions.fish}
      sed -i "s|/usr/local/sbin /sbin /usr/sbin||"         \
             $out/share/fish/completions/{sudo.fish,doas.fish}
      sed -e "s| awk | ${gawk}/bin/awk |"                  \
          -i $out/share/fish/functions/{__fish_print_packages.fish,__fish_print_addresses.fish,__fish_describe_command.fish,__fish_complete_man.fish,__fish_complete_convert_options.fish} \
             $out/share/fish/completions/{cwebp,adb,ezjail-admin,grunt,helm,heroku,lsusb,make,p4,psql,rmmod,vim-addons}.fish
      cat > $out/share/fish/functions/__fish_anypython.fish <<EOF
      function __fish_anypython
          echo ${python3.interpreter}
          return 0
      end
      EOF

      sed -e "s| ul| ${utillinux}/bin/ul|" \
          -i "$out/share/fish/functions/__fish_print_help.fish"
      for cur in $out/share/fish/functions/*.fish; do
        sed -e "s|/usr/bin/getent|${getent}/bin/getent|" \
            -i "$cur"
      done

      sed -i "s|Popen(\['manpath'|Popen(\['${man-db}/bin/manpath'|" \
              "$out/share/fish/tools/create_manpage_completions.py"
      sed -i "s|command manpath|command ${man-db}/bin/manpath|"     \
              "$out/share/fish/functions/man.fish"

      tee -a $out/share/fish/__fish_build_paths.fish < ${fishPreInitHooks}
    '';

    enableParallelBuilding = true;

    passthru.shellPath = "/bin/fish";
  };
in
fish
