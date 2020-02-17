{ config, lib, pkgs, ... }:

{
  # TODO: find more elegant solution
  _module.args.pkgs = import ./pkgs { inherit pkgs; };

  imports = [
    ./conf # ./pkgs
  ];

  programs = {
    # only for non-NixOS -- otherwise complains about locale
    man.enable = false;

    home-manager = {
      enable = true;
      path = "$HOME/workspace/git/home-manager";
    };
  };

  home = {
    packages = with pkgs; [
      ## nix-related
      nix # adds nix.sh to .nix-profile/etc/profile.d
      nix-index
      nixfmt
      cachix
      nixpkgs-fmt
      niv
      nox
      direnv
      # lorri
      # cached-nix-shell

      glibcLocales # to deal with locale issues on non-NixOS

      ## system-related
      # musl

      ## shell-related
      fish
      fzf
      # jq

      ## misc
      chatterino2
    ];

    extraOutputsToInstall = [ "man" ];

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "19.09";
  };

  services.lorri.enable = true;

  systemd.user = {
    services.lorri.Service.Environment = with lib;
      let path = with pkgs; makeSearchPath "bin" [ nix gitMinimal gnutar gzip ];
      # lorri complains about no nixpkgs because NIX_PATH is unset for it
      in mkForce [ "PATH=${path}" "NIX_PATH=%h/.nix-defexpr/channels" ];

    systemctlPath = "/usr/bin/systemctl";

    ## TODO: sessionVariables does not work with fish
    # sessionVariables = {
    #   LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
    # };
  };
}
