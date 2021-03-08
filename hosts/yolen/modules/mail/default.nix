{ config, ... }:
{
  age.secrets = {
    cole = {
      file = ./cole;
    };
  };

  security.acme.acceptTerms = true;
  security.acme.email = "cole.e.helbling@gmail.com";
  # https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/issues/182#note_342901583
  security.acme.certs."${config.mailserver.fqdn}".keyType = "rsa4096";

  mailserver =
    let
      domain = config.networking.domain;
    in
    {
      enable = true;
      mailDirectory = "/var/lib/mail";
      dkimKeyDirectory = "/var/lib/dkim";
      fqdn = "mail.${domain}";
      domains = [ domain ];

      loginAccounts = {
        "cole@${domain}" = {
          # nix shell nixpkgs#apacheHttpd -c htpasswd -nbB "" "super secret password" | cut -d: -f2
          hashedPasswordFile = config.age.secrets.cole.path;

          aliases = [
            "@${domain}"
          ];
        };
      };

      # Use Let's Encrypt certificates.
      certificateScheme = 3;

      # Enable IMAP and POP3
      enableImap = true;
      enablePop3 = true;
      enableImapSsl = true;
      enablePop3Ssl = true;

      # Enable the ManageSieve protocol
      enableManageSieve = true;
    };
}
