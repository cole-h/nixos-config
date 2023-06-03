{ pkgs, ... }:
{
  environment.systemPackages = with pkgs;
    [
      bottom # fancy top
      dnsutils # dig, nslookup
      exa # ls but better
      fd # find files
      ffmpeg # video conversion and stuff
      file # check file types
      hexyl # hex viewer
      htop # top but better
      libqalculate # greatest cli calculator ever, with conversions too
      ncdu # friendlier du
      nix-index # nix-locate
      nixpkgs-fmt # the better formatter
      nix-top # see what's building
      openssl # playing with tls and more
      par # nice paragraph formatter
      ripgrep # grep but better
      rsync # send files over ssh
      tokei # code metrics
    ];
}
