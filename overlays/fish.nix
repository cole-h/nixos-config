self: super:

let
  # fishPreInitHooks = ''
  #   # source nixos environment
  #   # note that this is required:
  #   #   1. For all shells, not just login shells (mosh needs this as do some other command-line utilities)
  #   #   2. Before the shell is initialized, so that config snippets can find the commands they use on the PATH
  #   builtin status --is-login
  #   or test -z "$__fish_nixos_env_preinit_sourced" -a -z "$ETC_PROFILE_SOURCED" -a -z "$ETC_ZSHENV_SOURCED"
  #   and test -f /etc/fish/nixos-env-preinit.fish
  #   and source /etc/fish/nixos-env-preinit.fish
  #   and set -gx __fish_nixos_env_preinit_sourced 1

  #   test -n "$NIX_PROFILES"
  #   and begin
  #     # We ensure that __extra_* variables are read in $__fish_datadir/config.fish
  #     # with a preference for user-configured data by making sure the package-specific
  #     # data comes last. Files are loaded/sourced in encounter order, duplicate
  #     # basenames get skipped, so we assure this by prepending Nix profile paths
  #     # (ordered in reverse of the $NIX_PROFILE variable)
  #     #
  #     # Note that at this point in evaluation, there is nothing whatsoever on the
  #     # fish_function_path. That means we don't have most fish builtins, e.g., `eval`.

  #     # additional profiles are expected in order of precedence, which means the reverse of the
  #     # NIX_PROFILES variable (same as config.environment.profiles)
  #     set -l __nix_profile_paths (echo $NIX_PROFILES | ${super.coreutils}/bin/tr ' ' '\n')[-1..1]

  #     set __extra_completionsdir \
  #       $__nix_profile_paths"/etc/fish/completions" \
  #       $__nix_profile_paths"/share/fish/vendor_completions.d" \
  #       $__extra_completionsdir
  #     set __extra_functionsdir \
  #       $__nix_profile_paths"/etc/fish/functions" \
  #       $__nix_profile_paths"/share/fish/vendor_functions.d" \
  #       $__extra_functionsdir
  #     set __extra_confdir \
  #       $__nix_profile_paths"/etc/fish/conf.d" \
  #       $__nix_profile_paths"/share/fish/vendor_conf.d" \
  #       $__extra_confdir
  #   end
  # '';
in {
  fish = super.fish.overrideAttrs (old: rec {
    version = "3.1.0";

    patches = [ ];

    src = super.fetchurl {
      url =
        "https://github.com/fish-shell/fish-shell/releases/download/${version}/${old.pname}-${version}.tar.gz";
      sha256 = "0s2356mlx7fp9kgqgw91lm5ds2i9iq9hq071fbqmcp3875l1xnz5";
    };

    postInstall = "";
  });
}
